class RidesController < ApplicationController
  include GoogleMapApiHelper

  def create_request
    @riderequest = Ride.new(request_params)
    puts @riderequest.pickup_end
    puts DateTime.now
    if @riderequest.save
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
    request = nil
    success = Ride.transaction do
      request = Ride.find(params[:rid])
      request.lock!
      raise ActiveRecord::Rollback unless request.driver_id.nil?
      request.update!(driver_id: current_user.id)
      true
    end
    if success
      @driver = current_user
      ActionCable.server.broadcast "request_channel/#{request.id}",
                                   accepted: ApplicationController.render(partial: 'rides/request_accepted',
                                                                          locals: { driver: @driver })
      render 'take_request'
    else
      redirect_to request_path, format: :js
    end
  end

  private

    def select_request requests, last_denied
      if last_denied
        time = Time.parse(last_denied)
        requests = requests.order(:created_at).where("created_at > ?", time+1)
      else
        requests = requests.order(:created_at)
      end
      @riderequest = requests.find do |request|
        @response = direction_if_pickup_coor(request, @drive)
      end
    end

    def read_time time_hash
      begin
        time = DateTime.parse time_hash[:hour]+":"+time_hash[:minute],
                              DateTime.now.in_time_zone(cookies['browser.timezone'])
        if time_hash[:day]=="1"
          time += 1.days
        end
        return time
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
end
