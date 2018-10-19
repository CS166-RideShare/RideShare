class UserController < ApplicationController
  skip_before_action :check_login, only: [:new, :create]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # add by csy
      log_in @user
      flash[:success] = "Welcome to Brandeis Ride Share!"
      redirect_to user_url(@user)
    else
      render 'new'
    end
  end
  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
