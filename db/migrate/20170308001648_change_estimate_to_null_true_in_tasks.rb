class ChangeEstimateToNullTrueInTasks < ActiveRecord::Migration
  def change
    change_column :tasks, :estimate, :integer, :null => true
  end
end
