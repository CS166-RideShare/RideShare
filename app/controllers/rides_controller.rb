class RidesController < ApplicationController
  include GoogleMapApiHelper

  def create_request
    create_params = request_params
    create_params[:rider_id] = current_user.id
    create_params[:pickup_start] = read_time create_params[:pickup_start]
    create_params[:pickup_end] = read_time create_params[:pickup_end]
    puts create_params
    @riderequest = Ride.new(create_params)
    if @riderequest.save
      render 'create_request'
    else
      flash.now[:danger] = 'Invalid input'
      render 'cancel_request'
    end
  end

  def cancel_request
    riderequest = Ride.find(params[:rid])
    @riderequest = riderequest.dup
    riderequest.destroy
  end

  def show_request
    if params[:commit] == "Cancel Drive"
      render 'cancel_drive' and return
    end
    if params[:commit] == "Pass"
      session[:last_denied] = params[:request][:created_at]
    end

    scheduled_time = read_time drive_params[:scheduled_time]

    @riderequest = nil
    @response = nil
    if requests = Ride.available.where.not(rider_id: current_user.id)
      select_request requests, session[:last_denied]
    end
    @drive = drive_params
  end

  def take_request
    request = Ride.find(params[:rid])
    success = Ride.transaction do
      request.lock!
      raise ActiveRecord::Rollback unless request.driver_id.nil?
      request.update!(driver_id: current_user.id)
      true
    end
    if success
      ActionCable.server.broadcast "request_channel/#{request.id}",
                                   accepted: ApplicationController.render(partial: 'rides/request_accepted',
                                                                          locals: { driver_name: current_user.name })
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
        @response = direction_if_pickup_coor(request, drive_params)
      end
    end

    def read_time time_hash
      time = Time.parse time_hash[:hour]+":"+time_hash[:minute], Time.now
      if time_hash[:day]=="1"
        time += 1.days
      end
      time
    end

    def request_params
      params.require(:request).permit(:destination_id,
                                      :destination_address,
                                      :starting_id,
                                      :starting_address,
                                      :destination_lat,
                                      :destination_lng,
                                      :starting_lat,
                                      :starting_lng,
                                      pickup_start: [:day, :hour, :minute],
                                      pickup_end: [:day, :hour, :minute])
    end

    def drive_params
      params.require(:drive).permit(:destination_id,
                                    :destination_address,
                                    :starting_id,
                                    :starting_address,
                                    :destination_lat,
                                    :destination_lng,
                                    :starting_lat,
                                    :starting_lng,
                                    :duration,
                                    scheduled_time: [:day, :hour, :minute])
    end
end
