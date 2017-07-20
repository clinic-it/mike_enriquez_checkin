class V1::StoriesController < V1::ApplicationController

  def index
    tasks = Task.all.uniq

    result = tasks.where.not(:project_id => 100000).map do |t|
      {
        :project_id => t.project.pivotal_id,
        :estimate => t.estimate,
        :title => t.title,
        :days_worked => days_worked(t),
        :owner_id => t.user_id
      }
    end

    render(
      :json => {
        :stories => result
      }
    )
  end



  private

  def days_worked task
    Task.where(:title => task.title, :current => true).count
  end

end
