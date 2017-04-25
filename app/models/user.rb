class User < ActiveRecord::Base

  has_many :checkins
  has_many :blockers
  has_many :tasks

end
