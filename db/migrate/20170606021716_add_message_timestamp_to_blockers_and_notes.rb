class AddMessageTimestampToBlockersAndNotes < ActiveRecord::Migration
  def change
    add_column :blockers, :message_timestamp, :string
    add_column :notes, :message_timestamp, :string
    add_column :user_checkins, :message_timestamp, :string
  end
end
