class CreateUserCheckins < ActiveRecord::Migration
  def change
    create_table :user_checkins do |t|

      t.timestamps null: false
    end
  end
end
