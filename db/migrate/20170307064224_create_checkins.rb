class CreateCheckins < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
      t.date :checkin_date, :null => false, :unique => true

      t.timestamps null: false
    end
  end
end
