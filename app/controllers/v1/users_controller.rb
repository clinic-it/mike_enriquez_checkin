class V1::UsersController < V1::ApplicationController

  def index
    users = User.all

    result = users.map do |u|
      {
        :pivotal_owner_id => u.pivotal_owner_id,
        :username => u.username,
        :fullname => u.fullname
      }
    end

    render(
      :json => {
        :users => result
      }
    )
  end

end
