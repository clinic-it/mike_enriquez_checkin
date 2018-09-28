class WorksController < ApplicationController

  before_action :freshbooks_init,
    :only => [
      :freshbooks_projects_data,
      :freshbooks_tasks_data,
      :freshbooks_log_hours,
      :freshbooks_time_entries_data
    ]

  def index

  end

  def pivotal_projects_data
    render :json => pivotal_request('https://www.pivotaltracker.com/services/v5/projects', request.method)
  end

  def pivotal_project_stories_data
    stories = pivotal_request("https://www.pivotaltracker.com/services/v5/projects/#{params[:project_id]}/stories?filter=owner:#{current_user.pivotal_owner_id}", request.method)
    stories = JSON.parse(stories).map{|story| story.merge('freshbooks_task_id' => current_user.freshbooks_task_id)}

    render :json => stories
  end

  def pivotal_update_state
    request_params = {
     'current_state' => params[:new_state]
    }

    pivotal_request("https://www.pivotaltracker.com/services/v5/projects/#{params[:project_id]}/stories/#{params[:story_id]}", request.method, request_params)

    render :nothing => true
  end

  def freshbooks_projects_data
    render :json => @user.project.list(:per_page => 100)
  end

  def freshbooks_tasks_data
    render :json => @user.task.list(:per_page => 100)
  end

  def freshbooks_log_hours
    @user.time_entry.create(
      :time_entry => {
        :project_id => params[:project_id],
        :task_id => params[:task_id],
        :hours => params[:hours],
        :notes => params[:notes],
        :date => params[:date]
      }
    )

    render :nothing => true
  end

  def freshbooks_time_entries_data
    entries = @user.time_entry.list :per_page => 100
    calendar_data = []

    entries['time_entries']['time_entry'].each do |time_entry|
      object = {
        :title => time_entry['project_id'],
        :start => Date.strptime(time_entry['date'], '%Y-%m-%d').strftime('%Y-%m-%dT%H:%M:%S+%H:%M'),
        :end => Date.strptime(time_entry['date'], '%Y-%m-%d').strftime('%Y-%m-%dT%H:%M:%S+%H:%M'),
        :task_id => time_entry['task_id'],
        :hours => time_entry['hours'],
        :notes => time_entry['notes']
      }

      calendar_data.push(object)
    end

    render :json => calendar_data
  end



  private

  def freshbooks_init
    @user = FreshBooks::Client.new 'clinicdev.freshbooks.com', current_user.freshbooks_token
  end

end


