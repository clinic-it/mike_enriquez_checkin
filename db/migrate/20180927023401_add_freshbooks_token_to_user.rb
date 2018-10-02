class AddFreshbooksTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :freshbooks_token, :string
  end
end
