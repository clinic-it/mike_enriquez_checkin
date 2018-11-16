class WorksController < ApplicationController

  before_action :admin_authorize
  before_action :freshbooks_init,
    :only => [
      :freshbooks_projects_data, :freshbooks_tasks_data, :freshbooks_log_hours,
      :freshbooks_delete_logged_hours, :freshbooks_time_entries_data
    ]



  def pivotal_projects_data
    render :json => PivotalRequest.get_projects_data(current_user.pivotal_token)
  end


  def pivotal_project_stories_data
    stories = PivotalRequest.get_my_project_stories_data current_user, params
    stories =
      JSON.parse(stories).map do |story|
        story.merge :freshbooks_task_id => current_user.freshbooks_task_id
      end

    render :json => stories
  end


  def pivotal_update_state
    request_params = {
     'current_state' => params[:new_state]
    }

    PivotalRequest.update_story_state current_user, params, request_params

    head :ok
  end


  def freshbooks_projects_data
    render :json => @user.project.list(:per_page => 100)
  end


  def freshbooks_tasks_data
    render :json => @user.task.list(:per_page => 100)
  end


  def freshbooks_log_hours
    if params[:entry_id].present?
      @user.time_entry.update(
        :time_entry => {
          :time_entry_id => params[:entry_id],
          :project_id => params[:project_id],
          :task_id => params[:task_id],
          :hours => params[:hours],
          :notes => params[:notes],
          :date => params[:date]
        }
      )

      response = params[:entry_id]
    else
      response = @user.time_entry.create(
        :time_entry => {
          :project_id => params[:project_id],
          :task_id => params[:task_id],
          :hours => params[:hours],
          :notes => params[:notes],
          :date => params[:date]
        }
      )['time_entry_id']
    end

    render :json => response
  end


  def freshbooks_delete_logged_hours
    @user.time_entry.delete :time_entry_id => params[:entry_id]

    render :json => params[:entry_id]
  end


  def freshbooks_time_entries_data
    entries = @user.time_entry.list :per_page => 100
    calendar_data = []

    entries['time_entries']['time_entry'].each do |time_entry|
      object = {
        :id => time_entry['time_entry_id'],
        :title => time_entry['project_id'],
        :start =>
          Date.strptime(time_entry['date'], '%Y-%m-%d').
            strftime('%Y-%m-%dT%H:%M:%S+%H:%M'),
        :end =>
          Date.strptime(time_entry['date'], '%Y-%m-%d').
            strftime('%Y-%m-%dT%H:%M:%S+%H:%M'),
        :task_id => time_entry['task_id'],
        :hours => time_entry['hours'],
        :notes => time_entry['notes'],
        :date => time_entry['date']
      }

      calendar_data.push object
    end

    render :json => calendar_data
  end




  private

  def freshbooks_init
    @user =
      FreshBooks::Client.new(
        ENV['freshbooks_url'], current_user.freshbooks_token
      )
  end

end


