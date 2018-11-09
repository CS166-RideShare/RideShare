class UsersController < ApplicationController
  skip_before_action :check_login, only: [:new, :create]

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    user = User.find(params[:id])
    user.update!(user_info_params)
    redirect_to user
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
      params.require(:user).permit(:name, :email, :is_driver,
                                   :password,
                                   :password_confirmation)
    end

    def user_info_params
      params.require(:user).permit(:name, :email, :is_driver, :profile_image)
    end
end
