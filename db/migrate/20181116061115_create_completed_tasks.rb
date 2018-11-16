class CreateCompletedTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :completed_tasks do |t|
      t.string :project_title
      t.string :story_title
      t.float :estimate
      t.timestamp :occured
      t.references :user
      t.timestamps
    end
  end
end
