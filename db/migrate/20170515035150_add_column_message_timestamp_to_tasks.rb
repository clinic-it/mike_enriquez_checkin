class AddColumnMessageTimestampToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :message_timestamp, :string
  end
end
