class RidesController < ApplicationController
  include GoogleMapApiHelper

  def create_request
    create_params = request_params
    create_params[:rider_id] = current_user.id
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
    @riderequest = nil
    @response = nil
    if Ride.available
      if session[:last_denied]
        time = Time.parse(session[:last_denied])
        requests = Ride.available.order(:created_at)
                       .where("created_at > ?", time+1)
      else
        requests = Ride.available.order(:created_at)
      end
      requests.each do |request|
        if @response = direction_if_pickup_coor(request,
                                           drive_params)
          @riderequest = request
        end
      end
      @drive = params[:drive]
    end
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

    def request_params
      params.require(:request).permit(:destination_id,
                                      :destination_address,
                                      :starting_id,
                                      :starting_address,
                                      :destination_lat,
                                      :destination_lng,
                                      :starting_lat,
                                      :starting_lng,
                                      :pickup_time)
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
                                    :pickup_time,
                                    :duration)
    end
end
