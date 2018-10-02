class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authorize

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  def authorize
    redirect_to :root unless current_user
  end

  def pivotal_request uri, method, params = {}
    uri = URI.parse uri
    request = eval("Net::HTTP::#{method.humanize}").new uri

    request['X-Trackertoken'] = current_user.pivotal_token

    if params.present?
      request.content_type = 'application/json'
      request.body = JSON.dump params
    end

    req_options = {
      use_ssl: uri.scheme == 'https',
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request request
    end

    response.body
  end

end
