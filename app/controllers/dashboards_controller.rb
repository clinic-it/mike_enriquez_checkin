class DashboardsController < ApplicationController

  before_action :init, :only => [:index]


  def index
    @pivotal.projects.each do |project|
      @project_hash[project.name] = []

      [project.iterations(:scope => 'done', :offset => -1), project.iterations(:scope => 'current_backlog')].flatten.each do |iteration|

        project_stories = iteration.stories.map do |story|
          owner_ids = [story.owner_ids].flatten

          if owner_ids.include? @user.pivotal_owner_id
            {
              :project_id => story.project_id,
              :title => story.name,
              :url => story.url,
              :current_state => story.current_state,
              :estimate => story.estimate,
              :task_type => story.story_type,
              :task_id => story.id
            }
          else
            nil
          end
        end

        @project_hash[project.name].push project_stories.compact
      end

      @project_hash[project.name].flatten!
    end
  end



  private

  def init
    @checkin = CheckinForm.new Checkin.new
    @user = User.find_by_id current_user
    @pivotal = TrackerApi::Client.new :token =>  @user.pivotal_token

    fetch_owner_id if @user.pivotal_owner_id.nil?

    @project_hash = {}
  end

  def fetch_owner_id
    @user.update_attributes :pivotal_owner_id => @pivotal.me.id
  end

end
