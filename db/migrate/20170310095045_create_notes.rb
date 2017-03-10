class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :checkin, :null => false
      t.references :user, :null => false
      t.string :description

      t.timestamps null: false
    end
  end
end
