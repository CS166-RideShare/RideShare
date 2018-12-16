class MainPagesController < ApplicationController
  skip_before_action :check_login, only: [:front]

  def home
    @role = 'rider'
    if params[:role]=='driver'
      @role = 'driver'
    end
    @user = current_user
    @r_notices = current_user.notices.for_request
    @d_notices = current_user.notices.for_driving
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
