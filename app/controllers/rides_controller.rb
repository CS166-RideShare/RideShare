class RidesController < ApplicationController
  include GoogleMapApiHelper

  def create_request
    @riderequest = Ride.new(request_params)
    if @riderequest.save
      RequestCleanupJob.set(wait_until: @riderequest.pickup_end)
                       .perform_later(@riderequest.id)
      render 'create_request'
    else
      render 'error_request', locals: { errors: @riderequest.errors }
    end
  end

  def cancel_request
    @timezone = cookies['browser.timezone']
    @riderequest = Ride.find(params[:rid])
    @ride = @riderequest.destroy
  end

  def show_request
    @timezone = cookies['browser.timezone']
    @drive = Ride.new(drive_params)
    @ride = @drive

    if params[:commit] == "Cancel Drive"
      render 'cancel_drive' and return
    end
    if !@drive.validate_drive
      render 'error_drive', locals: { errors: @drive.errors } and return
    end
    if params[:commit] == "Pass"
      session[:last_denied] = params[:request][:created_at]
    end
    @riderequest = nil
    @response = nil
    requests = Ride.available.where.not(rider_id: current_user.id)
    if requests.any?
      select_request requests, session[:last_denied]
    end
    render 'show_request'
  end

  def take_request
    @ride = nil
    success = Ride.transaction do
      @ride = Ride.find(params[:rid])
      @ride.lock!
      raise ActiveRecord::Rollback unless @ride.driver_id.nil?
      @ride.update!(driver_id: current_user.id)
      true
    end
    if success
      @drive = @ride
      @rider = @drive.rider
      @driver = current_user
      notice = Notice.create!(
        ride_id: @ride.id,
        user_id: @ride.rider.id,
        target: 'request',
        kind: 'accepted',
        content: accepted_request_notice
        )
      ActionCable.server.broadcast "request_channel/#{@rider.id}",
                                   request_id: @ride.id,
                                   accepted: ApplicationController.render(partial: 'rides/accepted_request',
                                                                          locals: { driver: @driver, ride: @ride }),
                                   notice_id: notice.id,
                                   notice_content: notice.content,
                                   notice: "You have #{@ride.rider.notices.for_request.where(kind: "accepted").size} requests accepted!"
      render 'take_request'
    else
      redirect_to request_path, format: :js
    end
  end

  def cancel_ride
    @ride = Ride.find(params[:rid])
    @ride.update(canceled_by: params[:canceled_by].to_i)
    if params[:canceled_by].to_i==0
      notice = Notice.create!(
        ride_id: @ride.id,
        user_id: @ride.driver.id,
        target: 'driving',
        kind: 'canceled',
        content: canceled_drive_notice
        )
      ActionCable.server.broadcast "cancel_notice/#{@ride.driver.id}",
                                   target: 'driver',
                                   ride_id: @ride.id,
                                   accepted: ApplicationController.render(partial: 'rides/canceled_drive',
                                                                          locals: { rider: @ride.rider }),
                                   notice_id: notice.id,
                                   notice_content: notice.content,
                                   notice: "You have #{@ride.driver.notices.for_driving.where(kind: "canceled").size} drives canceled."
      render 'cancel_request'
    else
      notice = Notice.create!(
        ride_id: @ride.id,
        user_id: @ride.rider.id,
        target: 'request',
        kind: 'canceled',
        content: canceled_ride_notice
        )
      ActionCable.server.broadcast "cancel_notice/#{@ride.rider.id}",
                                   target: 'rider',
                                   ride_id: @ride.id,
                                   accepted: ApplicationController.render(partial: 'rides/canceled_ride',
                                                                          locals: { driver: @ride.driver }),
                                   notice_id: notice.id,
                                   notice_content: notice.content,
                                   notice: "You have #{@ride.rider.notices.for_request.where(kind: "canceled").size} requests canceled."
      render 'cancel_drive'
    end
  end

  def new_ride
    ride = Ride.new(ride_params)
    if params[:ride]=='request'
      @ride = ride
      @riderequest = ride
      render 'cancel_request'
    else
      @ride = ride
      @drive = ride
      render 'cancel_drive'
    end
  end

  def finish_ride
    @ride = Ride.find(params[:rid])
    @ride.update(finished: true)
    @rider = @ride.rider
    @driver = @ride.driver
    notice = Notice.create!(
      ride_id: @ride.id,
      user_id: @ride.rider.id,
      target: 'request',
      kind: 'finished',
      content: finished_ride_notice
      )
    ActionCable.server.broadcast "finish_notice/#{@rider.id}",
                                 ride_id: @ride.id,
                                 accepted: ApplicationController.render(partial: 'rides/review_drive',
                                                                        locals: { driver: @driver, ride: @ride }),
                                 notice_id: notice.id,
                                 notice_content: notice.content,
                                 notice: "You have #{@ride.rider.notices.for_request.where(kind: "finished").size} requests finished!"
    render 'finish_drive'
  end

  def review_ride
    if params[:role]=='driver'
      to_render = 'cancel_drive'
    else
      to_render = 'cancel_request'
    end
    @ride = Ride.find(params[:rid])
    @review = Review.new(review_params)
    if @review.save
      render to_render
    else
      return
    end
  end

  def review_trip
    if params[:target]=='driver'
      to_render = 'review_drive'
    else
      to_render = 'review_ride'
    end
    @ride = Ride.find(params[:rid])
    render 'review_trip', locals: { to_render: to_render }
  end

  def details
    details = 'details_' + params[:details]
    @ride = Ride.find(params[:id])
    render 'details', locals: { content: details }
  end

  private

    def select_request requests, last_denied
      requests = requests.order(:created_at)
      if last_denied
        time = Time.parse(last_denied)
        requests = requests.where("created_at > ?", time+1)
      end
      @riderequest = requests.find do |request|
        if request.pickup_start<=@drive.scheduled_time &&
           request.pickup_end>=@drive.scheduled_time
          @response = direction_if_pickup_coor(request, @drive)
        end
        !@response.nil?
      end
    end

    def read_time time_string
      begin
        time = Time.find_zone(cookies['browser.timezone'])
                   .strptime(time_string, '%m/%d/%Y %H:%M %p')
        return DateTime.parse(time.to_s)
      rescue
        return nil
      end
    end

    def ride_params
      params.permit(:destination_id,
                    :destination_address,
                    :starting_id,
                    :starting_address,
                    :destination_lat,
                    :destination_lng,
                    :starting_lat,
                    :starting_lng,
                    :duration)
    end

    def request_params
      temp_params = params.require(:request)
                          .permit(:destination_id,
                                  :destination_address,
                                  :starting_id,
                                  :starting_address,
                                  :destination_lat,
                                  :destination_lng,
                                  :starting_lat,
                                  :starting_lng,
                                  :start_time,
                                  :end_time,
                                  :pickup_start,
                                  :pickup_end)
      temp_params[:rider_id] = current_user.id

      temp_params[:pickup_start] = read_time temp_params[:pickup_start]
      temp_params[:pickup_end] = read_time temp_params[:pickup_end]

      temp_params
    end

    def drive_params
      temp_params = params.require(:drive)
                          .permit(:destination_id,
                                  :destination_address,
                                  :starting_id,
                                  :starting_address,
                                  :destination_lat,
                                  :destination_lng,
                                  :starting_lat,
                                  :starting_lng,
                                  :duration,
                                  :scheduled_time)

      temp_params[:scheduled_time] = read_time temp_params[:scheduled_time]
      temp_params[:duration] = temp_params[:duration].to_i

      temp_params
    end

    def review_params
      temp = params.require(:review).permit(:target, :review, :review_level)
      temp[:ride_id] = params[:rid].to_i
      temp
    end

    def accepted_request_notice
      %Q{
        Your ride from #{@ride.short_starting} to #{@ride.short_destination}
        between #{@ride.pickup_start.to_s(:short)} and #{@ride.pickup_end.to_s(:short)}
        has been accepted by #{@ride.driver.name}
      }
    end

    def canceled_ride_notice
      %Q{
        Your ride from #{@ride.short_starting} to #{@ride.short_destination}
        between #{@ride.pickup_start.to_s(:short)} and #{@ride.pickup_end.to_s(:short)}
        has been canceled by #{@ride.driver.name}
      }
    end

    def canceled_drive_notice
      %Q{
        The ride from #{@ride.short_starting} to #{@ride.short_destination}
        between #{@ride.pickup_start.to_s(:short)} and #{@ride.pickup_end.to_s(:short)}
        has been canceled by #{@ride.rider.name}
      }
    end

    def finished_ride_notice
      %Q{
        Your ride from #{@ride.short_starting} to #{@ride.short_destination}
        has finished on #{@ride.updated_at.to_s(:short)}
      }
    end
end
