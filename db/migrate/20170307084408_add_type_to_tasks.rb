class AddTypeToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :task_type, :string, :null => false, :default => 'feature'
  end
end
