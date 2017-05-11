class Task < ActiveRecord::Base

  belongs_to :user
  belongs_to :project
  belongs_to :checkin

  scope :current, -> { where :current => true }

  def week
    self.created_at.strftime '%W'
  end

  def self.week_dates week_num
    year = Time.now.year
    week_start = Date.commercial year, week_num.to_i, 1
    week_end = Date.commercial year, week_num.to_i, 7

    week_start.strftime('%m/%d/%y') + ' - ' + week_end.strftime('%m/%d/%y')
  end

end
