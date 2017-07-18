class DashboardsController < ApplicationController

  def index
    @checkin = CheckinForm.new Checkin.new
    user = User.find_by_id current_user
    pivotal = TrackerApi::Client.new :token =>  user.pivotal_token

    @project_hash = {}

    pivotal.projects.each do |project|
      @project_hash[project.name] = []

      project.iterations(:scope => 'current_backlog').each do |iteration|
        @project_hash[project.name].push iteration.stories.map{|story| {:project_id => story.project_id, :title => story.name, :url => story.url, :current_state => story.current_state, :estimate => story.estimate, :task_type => story.story_type, :task_id => story.id}}
      end

      @project_hash[project.name].flatten!
    end

  end

end
