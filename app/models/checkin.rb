# == Schema Information
#
# Table name: checkins
#
#  id           :integer          not null, primary key
#  checkin_date :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Checkin < ApplicationRecord

  paginates_per 10

  CHECKIN_DAYS = [
    'yesterday',
    'today'
  ]

  has_many :tasks, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :blockers, :dependent => :destroy
  has_many :user_checkins, :dependent => :destroy

  scope :span_previous_month,
    -> { where('checkin_date BETWEEN ? AND ?', 1.month.ago.beginning_of_day, Date.today.end_of_day) }


  def submitted_checkins
    self.user_checkins.map(&:user_id).uniq.count
  end

  def pending_checkins
    User.where.not(:admin => true, :active => false).count - self.submitted_checkins
  end

  def users_with_checkin
    self.user_checkins.map(&:user).uniq
  end

  def average_load
    user_count = self.tasks.map(&:user_id).uniq.count

    value = self.tasks.current.sum(:estimate) / user_count.to_f

    return value.nan? ? 0 : value
  end

  def lowest_load
    tasks_per_user = self.tasks.current.group_by(&:user_id)

    task_load = []
    tasks_per_user.each_value do |tasks|
      task_load.push task_sum(tasks)
    end

    return task_load.sort.first.nil? ? 0 : task_load.sort.first
  end

  def highest_load
    tasks_per_user = self.tasks.current.group_by(&:user_id)

    task_load = []
    tasks_per_user.each_value do |tasks|
      task_load.push task_sum(tasks)
    end

    return task_load.sort.reverse.first.nil? ? 0 : task_load.sort.reverse.first
  end



  private

  def task_sum tasks
    tasks.sum{|task| task.estimate ? task.estimate : 0}
  end

end
