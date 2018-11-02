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
    if session[:last_denied]
      puts "----------------------"
      puts session[:last_denied]
      @riderequest = Ride.available
                         .order(:created_at)
                         .find_by("created_at > ?", session[:last_denied])
      puts "----------------------"
      puts @riderequest.created_at
    else
      @riderequest = Ride.available.order(:created_at).first
    end
  end

  def take_request
    Ride.transaction do
      request = Ride.find(params[:rid])
      raise ActiveRecord::Rollback unless request.driver_id.nil?
      request.update!(driver_id: current_user.id)
    end
  end

  private

    def request_params
      params.require(:ride).permit(:destination,
                                   :scheduled_time)
    end
end
