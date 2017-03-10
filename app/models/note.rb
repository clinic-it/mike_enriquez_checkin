class Note < ActiveRecord::Base

  belongs_to :checkin
  belongs_to :user
  
end
