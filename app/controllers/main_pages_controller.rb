class MainPagesController < ApplicationController
  skip_before_action :check_login, only: [:front]
  
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

  def emergency
    account_sid = 'ACd1c65c57e8de3b621a79f1634bfb2653'
    auth_token = 'f2358b3632de41a566141ddd81428814'
    client = Twilio::REST::Client.new(account_sid, auth_token)

    from = '+13519998634' # Your Twilio number
    to = '+1' + current_user.emergency_contact # Your mobile phone number

    client.messages.create(
      from: from,
      to: to,
      body: "This is a test message from RideShare"
    )
  end

  def front

  end
end
