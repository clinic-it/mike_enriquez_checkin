class SessionsController < ApplicationController

  skip_before_action :authorize



  def new
    redirect_to dashboards_path if current_user.present?
  end


  def create
   user = User.find_by_username params[:session][:username].downcase

   if user && user.authenticate(params[:session][:password])
     session[:user_id] = user.id

     return redirect_to summary_index_path if user.pivotal_token.nil? || user.admin?

     redirect_to dashboards_path
   else
     flash[:error] = 'Username/Password is incorrect'

     redirect_to root_path
   end
 end


 def destroy
   session[:user_id] = nil

   redirect_to root_path
 end

end
