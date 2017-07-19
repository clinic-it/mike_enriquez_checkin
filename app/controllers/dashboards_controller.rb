class DashboardsController < ApplicationController

  before_action :init, :only => [:index]

  
  def index
    @pivotal.projects.each do |project|
      @project_hash[project.name] = []

      [project.iterations(:scope => 'done', :offset => -1), project.iterations(:scope => 'current_backlog')].flatten.each do |iteration|
        @project_hash[project.name].push iteration.stories.map{|story| {:project_id => story.project_id, :title => story.name, :url => story.url, :current_state => story.current_state, :estimate => story.estimate, :task_type => story.story_type, :task_id => story.id}}
      end

      @project_hash[project.name].flatten!
    end
  end



  private

  def init
    @checkin = CheckinForm.new Checkin.new
    user = User.find_by_id current_user
    @pivotal = TrackerApi::Client.new :token =>  user.pivotal_token

    @project_hash = {}
  end

end
