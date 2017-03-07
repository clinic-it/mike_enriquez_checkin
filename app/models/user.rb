class User < ActiveRecord::Base

  has_many :checkins
  has_many :blockers

end
