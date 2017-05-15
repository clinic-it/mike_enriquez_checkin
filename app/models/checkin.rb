class Checkin < ActiveRecord::Base

  paginates_per 10

  has_many :tasks
  has_many :notes
  has_many :blockers
  has_many :checkins

end
