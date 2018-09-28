class AddFreshbooksTaskIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :freshbooks_task_id, :string
  end
end
