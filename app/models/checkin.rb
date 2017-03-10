class Checkin < ActiveRecord::Base

  has_many :tasks
  has_many :notes
  has_many :blockers
  has_many :checkins

end
