class SessionsController < ApplicationController

  skip_before_action :authorize, :only => [:create, :destroy]

  def create
   user = User.find_by_username params[:session][:username].humanize

   if user && user.authenticate(params[:session][:password])
     session[:user_id] = user.id

     return redirect_to summary_path if user.pivotal_token.nil?

     redirect_to dashboard_path
   else
     flash[:error] = 'Username/Password is incorrect'
     redirect_to :root
   end
 end

 def destroy
   session[:user_id] = nil
   redirect_to :root
 end

end
