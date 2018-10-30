class RidesController < ApplicationController

  def new_request
    @riderequest = Ride.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_request
    respond_to do |format|
      format.html
      format.js
    end
  end
end
