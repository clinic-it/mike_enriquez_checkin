class Blocker < ActiveRecord::Base

  belongs_to :user
  belongs_to :checkin
  
end
