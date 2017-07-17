class DashboardsController < ApplicationController

  def index
    @checkin = CheckinForm.new Checkin.new
    pivotal = TrackerApi::Client.new(token: '0dbcbec6e4625e965dbdf5444dcb929d')

    @project_hash = {}

    pivotal.projects.each do |project|
      project.iterations(:scope => 'current_backlog').each do |iteration|
        @project_hash[project.name] = iteration.stories.map{|story| {:project_id => story.project_id, :title => story.name, :url => story.url, :current_state => story.current_state, :estimate => story.estimate, :task_type => story.story_type, :task_id => story.id}}
      end
    end

  end

end
