class MainPagesController < ApplicationController

  def home
    @riderequest = current_user.rides.available.first
    @drive = current_user.drives.unfinished.first
    request_form = 'request_form'
    drive_form = 'drive_form'
    if @riderequest
      request_form = 'rides/create_request'
    elsif @ride = current_user.rides.unfinished.first
      @driver = @ride.driver
      request_form = 'rides/request_accepted'
    end
    if @drive
      @rider = @drive.rider
      drive_form = 'rides/ongoing_drive'
    end
    render 'home', locals: { request_form: request_form, drive_form: drive_form }
  end
end
