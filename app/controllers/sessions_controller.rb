class SessionsController < ApplicationController
  skip_before_action :check_login, only: [:new, :create, :destroy]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      flash[:success] = "Welcome to Brandeis Ride Share!"
      redirect_to root_path
    else
      redirect_to front_path
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
