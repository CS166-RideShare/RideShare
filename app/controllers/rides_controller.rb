class RidesController < ApplicationController

  def new_request
    @riderequest = Ride.new
  end

  def create_request
    create_params = request_params
    create_params[:rider_id] = current_user.id
    @riderequest = Ride.new(create_params)
    if @riderequest.save
      render 'create_request'
    else
      flash.now[:danger] = 'Invalid input'
      render 'new_request'
    end
  end

  def cancel_request
    riderequest = Ride.find(params[:rid])
    riderequest.destroy
  end

  def show_request
    if params[:post_time]
      session[:last_denied] = params[:post_time]
    end
    @riderequest = nil
    if Ride.available
      if session[:last_denied]
        time = Time.parse(session[:last_denied])
        @riderequest = Ride.available
                           .order(:created_at)
                           .find_by("created_at > ?", time+1)
      else
        @riderequest = Ride.available.order(:created_at).first
      end
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
      params.require(:ride).permit(:destination,
                                   :scheduled_time)
    end
end
