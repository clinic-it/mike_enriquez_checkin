class ChangeEstimateToNullTrueInTasks < ActiveRecord::Migration
  def change
    change_column :tasks, :estimate, :integer, :null => true, :default => 0
  end
end
