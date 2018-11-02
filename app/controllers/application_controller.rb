class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :check_login
  include SessionsHelper
end
