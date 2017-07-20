class V1::UsersController < V1::ApplicationController

  def index
    users = User.all

    result = users.map do |user|
      serialize user
    end

    render(
      :json => {
        :users => result
      }
    )
  end

  def show
    user = User.find_by_pivotal_owner_id params[:id]

    result = serialize user

    render(
      :json => {
        :user => result
      }
    )
  end



  private

  def serialize user
    {
      :id => user.pivotal_owner_id,
      :username => user.username,
      :fullname => user.fullname
    }
  end

end
