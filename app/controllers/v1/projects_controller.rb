class V1::ProjectsController < V1::ApplicationController

  def index
    users = User.where.not :pivotal_token => nil
    projects = []

    users.each do |user|
      pivotal = TrackerApi::Client.new :token =>  user.pivotal_token

      projects.push pivotal.me.projects
    end


    render(
      :json => {
        :projects => projects[0]
      }
    )
  end

end
