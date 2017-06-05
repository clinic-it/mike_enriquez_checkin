class CreateUserCheckins < ActiveRecord::Migration
  def change
    create_table :user_checkins do |t|
      t.references :checkin
      t.references :user
      t.string :screenshot_path
      
      t.timestamps null: false
    end
  end
end
