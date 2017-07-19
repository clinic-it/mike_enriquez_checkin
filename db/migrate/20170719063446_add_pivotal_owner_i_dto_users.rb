class AddPivotalOwnerIDtoUsers < ActiveRecord::Migration
  def change
    add_column :users, :pivotal_owner_id, :integer
  end
end
