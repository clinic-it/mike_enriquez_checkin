class CreateTaskBlockers < ActiveRecord::Migration
  def change
    create_table :task_blockers do |t|
      t.references :task
      t.string :blocker_text

      t.timestamps :null => false
    end
  end
end
