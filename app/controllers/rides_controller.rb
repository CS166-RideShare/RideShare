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

  def check_request
  end

  def take_request
  end

  def deny_request
  end

  private

    def request_params
      params.require(:ride).permit(:destination,
                                   :scheduled_time)
    end
end
