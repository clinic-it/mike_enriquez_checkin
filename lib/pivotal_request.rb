class PivotalRequest

  def self.get_projects_data pivotal_token
    uri = URI.parse 'https://www.pivotaltracker.com/services/v5/projects'
    request = Net::HTTP::Get.new uri

    request['X-Trackertoken'] = pivotal_token

    get_response request, uri
  end


  def self.get_project_stories_data current_user, params
    url =
      'https://www.pivotaltracker.com/services/v5/projects/' \
        "#{params[:project_id]}/stories?filter=owner:" \
        "#{current_user.pivotal_owner_id}"
    uri = URI.parse url
    request = Net::HTTP::Get.new uri

    request['X-Trackertoken'] = current_user.pivotal_token

    get_response request, uri
  end


  def self.update_story_state current_user, params, request_params = {}
    url =
      'https://www.pivotaltracker.com/services/v5/projects/' \
        "#{params[:project_id]}/stories/#{params[:story_id]}"
    uri = URI.parse url
    request = Net::HTTP::Put.new uri

    request['X-Trackertoken'] = current_user.pivotal_token

    request.content_type = 'application/json'
    request.body = JSON.dump request_params

    get_response request, uri
  end




  private

  def self.get_response request, uri
    req_options = {
      :use_ssl => uri.scheme == 'https',
    }

    response =
      Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request request
      end

    response.body
  end

end
