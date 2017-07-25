class PivotalBlocker

  attr_accessor :blockers


  def initialize params
    headers = {
      'X-TrackerToken' => params[:token]
    }

    url = "https://www.pivotaltracker.com/services/v5/projects/#{params[:project_id]}/stories/#{params[:story_id]}/blockers"

    @blockers = HTTParty.get(url, :headers => headers)
  end

end
