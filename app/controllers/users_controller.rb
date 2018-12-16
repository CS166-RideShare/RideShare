class UsersController < ApplicationController
  skip_before_action :check_login, only: [:new, :create]

  def driving_index
    @user = current_user
    @r_notices = current_user.notices.for_request
    @d_notices = current_user.notices.for_driving.destroy_all
    render 'show', locals: {
      show_profile: nil,
      show_requests: nil,
      show_drivings: "show active"
    }
  end

  def request_index
    @user = current_user
    @r_notices = current_user.notices.for_request.destroy_all
    @d_notices = current_user.notices.for_driving
    render 'show', locals: {
      show_profile: nil,
      show_requests: "show active",
      show_drivings: nil
    }
  end

  def show
    @user = current_user
    @r_notices = current_user.notices.for_request
    @d_notices = current_user.notices.for_driving
    render 'show', locals: {
      show_profile: "show active",
      show_requests: nil,
      show_drivings: nil
    }
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(user_update_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_signup_params)
    if @user.save
      # add by csy
      log_in @user
      flash[:success] = "Welcome to Brandeis Ride Share!"
      redirect_to root_path
    else
      render 'new'
    end
  end

  def send_message
    begin
      @user = User.find(params[:id])
      account_sid = 'ACd1c65c57e8de3b621a79f1634bfb2653'
      auth_token = 'f2358b3632de41a566141ddd81428814'
      client = Twilio::REST::Client.new(account_sid, auth_token)

      from = '+13519998634' # Your Twilio number
      to = '+1' + @user.phone_number # Your mobile phone number

      client.messages.create(
        from: from,
        to: to,
        body: params[:content]
      )
    rescue StandardError => e
      puts e
    end
  end

  def clear_notices
    @user = current_user
    if params[:target] == 'driving'
      @user.notices.for_driving.destroy_all
    elsif params[:target] == 'request'
      @user.notices.for_request.destroy_all
    end
  end

  private

    def user_signup_params
      params.require(:user).permit(:name, :email, :is_driver, :phone_number, :emergency_contact,
                                   :password, :password_confirmation)
    end

    def user_info_params
      params.require(:user).permit(:name, :email, :is_driver, :profile_image, :vehicle_image)
    end

    def user_update_params
      params.require(:user).permit(:name, :phone_number, :email, :emergency_scontact, :profile_image, :vehicle_make, :license_number, :vehicle_model, :vehicle_plate, :vehicle_image)
    end
end
