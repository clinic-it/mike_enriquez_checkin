class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :project
      t.references :user
      t.references :checkin
      t.string :title, :null => false
      t.string :url, :null => false
      t.string :current_state
      t.integer :estimate, :null => false
      t.boolean :current, :null => false

      t.timestamps null: false
    end
  end
end
