class Checkin < ActiveRecord::Base

  paginates_per 10

  has_many :tasks, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :blockers, :dependent => :destroy
  has_many :user_checkins, :dependent => :destroy

  scope :span_previous_month,
    -> { where('checkin_date BETWEEN ? AND ?', 1.month.ago.beginning_of_day, Date.today.end_of_day) }

end
