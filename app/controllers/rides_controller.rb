class RidesController < ApplicationController

  def new_request
    @riderequest = Ride.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_request
    create_params = request_params
    create_params[:rider_id] = current_user.id
    @riderequest = Ride.new(create_params)
    p @riderequest.rider_id
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

    def request_params
      params.require(:ride).permit(:destination,
                                   :scheduled_time)
    end
end
