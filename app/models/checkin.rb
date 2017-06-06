class Checkin < ActiveRecord::Base

  paginates_per 10

  has_many :tasks, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :blockers, :dependent => :destroy
  has_many :user_checkins, :dependent => :destroy

end
