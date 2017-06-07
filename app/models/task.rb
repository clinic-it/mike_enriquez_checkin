class Task < ActiveRecord::Base

  belongs_to :user
  belongs_to :project
  belongs_to :checkin

  scope :current, -> { where :current => true }
  scope :previous, -> { where :current => false }
  scope :current_tasks_1month_ago,
    -> { current.where('tasks.created_at BETWEEN ? AND ?', 1.month.ago.beginning_of_day, Date.today.end_of_day) }

  def week
    self.created_at.strftime '%W'
  end

  def self.week_dates week_num
    year = Time.now.year
    week_start = Date.commercial year, week_num.to_i, 1
    week_end = Date.commercial year, week_num.to_i, 7

    week_start.strftime('%m/%d/%y') + ' - ' + week_end.strftime('%m/%d/%y')
  end

  def times_checked_in_current
    Task.where(:task_id => self.task_id, :current => true).count
  end

end
