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
    riderequest = Ride.find(params[:rid])
    @riderequest = riderequest.dup
    riderequest.destroy
  end

  def show_request
    @timezone = cookies['browser.timezone']
    @drive = Ride.new(drive_params)

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
      ActionCable.server.broadcast "request_channel/#{@ride.id}",
                                   accepted: ApplicationController.render(partial: 'rides/request_accepted',
                                                                          locals: { driver: @driver, ride: @ride })
      render 'take_request'
    else
      redirect_to request_path, format: :js
    end
  end

  def cancel_ride
    @ride = Ride.find(params[:rid])
    @ride.update(canceled_by: params[:canceled_by].to_i)
    if params[:canceled_by].to_i==0
      ActionCable.server.broadcast "cancel_notice/#{@ride.id}/driver",
                                   accepted: ApplicationController.render(partial: 'rides/canceled_drive',
                                                                          locals: { rider: @ride.rider })
      render 'cancel_request'
    else
      ActionCable.server.broadcast "cancel_notice/#{@ride.id}/rider",
                                   accepted: ApplicationController.render(partial: 'rides/canceled_ride',
                                                                          locals: { driver: @ride.driver })
      render 'cancel_drive'
    end
  end

  def new_ride
    if params[:ride]=='request'
      render 'cancel_request'
    else
      render 'cancel_drive'
    end
  end

  def finish_ride
    @ride = Ride.find(params[:rid])
    @ride.update(finished: true)
    @rider = @ride.rider
    @driver = @ride.driver
    ActionCable.server.broadcast "finish_notice/#{@ride.id}",
                                 accepted: ApplicationController.render(partial: 'rides/review_drive',
                                                                        locals: { driver: @driver, ride: @ride })
    render 'review_ride'
  end

  def review_ride
    if params[:role]=='driver'
      to_render = 'cancel_drive'
    else
      to_render = 'cancel_request'
    end
    puts review_params
    success = Review.transaction do
      @review = Ride.find(params[:id]).review
      raise ActiveRecord::Rollback unless @review.nil?
      @review = Review.new(review_params)
      @review.save!
    end
    if !success
      @review.update(review_params)
    end
    render to_render
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

    def read_time time_hash
      begin
        time = Time.find_zone(cookies['browser.timezone'])
                   .parse(time_hash[:hour]+":"+time_hash[:minute])
        if time_hash[:day]=="1"
          time += 1.days
        end
        return DateTime.parse(time.to_s)
      rescue
        return nil
      end
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
                                  pickup_start: [:day, :hour, :minute],
                                  pickup_end: [:day, :hour, :minute])

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
                                  scheduled_time: [:day, :hour, :minute])

      temp_params[:scheduled_time] = read_time temp_params[:scheduled_time]
      temp_params[:duration] = temp_params[:duration].to_i

      temp_params
    end

    def review_params
      if params[:role]=='driver'
        temp = params.require(:review).permit(:rider_review, :rider_review_level)
      else
        temp = params.require(:review).permit(:driver_review, :driver_review_level)
      end
      temp[:ride_id] = params[:id].to_i
      temp
    end
end
