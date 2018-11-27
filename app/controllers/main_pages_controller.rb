class MainPagesController < ApplicationController

  def home
    @riderequest = current_user.rides.available.first
    if @riderequest
      render 'home', locals: { request_form: 'rides/create_request' }
    elsif @riderequest = current_user.rides.unfinished.first
      driver_name = @riderequest.driver.name
      render 'home', locals: { request_form: 'rides/request_accepted',
                               driver_name: driver_name }
    else
      render 'home', locals: { request_form: 'request_form' }
    end
  end
end
