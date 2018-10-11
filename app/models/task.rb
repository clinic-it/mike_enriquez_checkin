# == Schema Information
#
# Table name: tasks
#
#  id                :integer          not null, primary key
#  project_id        :integer
#  user_id           :integer
#  checkin_id        :integer
#  title             :string           not null
#  url               :string           not null
#  current_state     :string
#  estimate          :integer          default(0)
#  current           :boolean          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  task_type         :string           default("feature"), not null
#  message_timestamp :string
#  task_id           :integer
#

class Task < ApplicationRecord

  belongs_to :user
  belongs_to :project
  belongs_to :checkin

  has_many :task_blockers

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

  def times_checked_in_current user_id
    count = Task.where(
      :task_id => self.task_id,
      :current => true,
      :user_id => user_id
    ).count

    count == 0 ? 1 : count
  end

end
