class HomeController < ApplicationController
  def index
    # Check if user is logged in
    @logged_in = session[:user_id].present?
    @user_email = session[:user_email] if @logged_in
  end
end
