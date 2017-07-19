class V1::StoriesController < V1::ApplicationController

  def index
    tasks = Task.all.uniq

    result = tasks.map do |t|
      {
        :project_id => t.project_id,
        :owner_id => t.user_id,
        :estimate => t.estimate,
        :title => t.title
      }
    end

    render(
      :json => {
        :stories => result
      }
    )
  end

end
