class AddPivotalAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pivotal_token, :string
  end
end
