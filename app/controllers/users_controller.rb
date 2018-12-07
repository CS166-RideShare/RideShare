class UsersController < ApplicationController
  skip_before_action :check_login, only: [:new, :create]

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    puts "***********#{@user.phone_number}"
    puts user_update_params
    respond_to do |format|
      if @user.update_attributes(user_update_params)
        puts "$$$$$$$$$"
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        puts "&&&&&&&&&&"
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
    puts "***********#{@user.phone_number}"
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
  
  private

    def user_signup_params
      params.require(:user).permit(:name, :email, :is_driver, :phone_number, :emergency_contact,
                                   :password, :password_confirmation)
    end

    def user_info_params
      params.require(:user).permit(:name, :email, :is_driver, :profile_image)
    end
    
    def user_update_params
      params.require(:user).permit(:name, :phone_number, :email, :emergency_contact, :profile_image)
    end
end
