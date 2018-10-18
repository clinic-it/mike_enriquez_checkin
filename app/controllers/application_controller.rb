class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception

  before_action :authorize




  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end


  helper_method :current_user


  def authorize
    redirect_to root_path unless current_user
  end


  def admin_authorize
    redirect_to summary_index_path if current_user && current_user.admin
  end

end
