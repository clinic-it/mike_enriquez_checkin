class V1::ProjectsController < V1::ApplicationController

  before_action :init, :only => [:index, :show]


  def index
    render(
      :json => {
        :projects => @projects[0]
      }
    )
  end

  def show
    project = Project.find_by_pivotal_id params[:id]

    result = project.present? ?
      @projects[0].find{|p| p[:project_id] == project.pivotal_id} :
      nil

    render(
      :json => {
        :project => result
      }
    )
  end



  private

  def init
    @projects = []
    users = User.where.not :pivotal_token => nil

    users.each do |user|
      pivotal = TrackerApi::Client.new :token =>  user.pivotal_token

      @projects.push pivotal.me.projects
    end
  end

end
