class Checkin < ActiveRecord::Base

  paginates_per 10

  has_many :tasks, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :blockers, :dependent => :destroy
  has_many :user_checkins, :dependent => :destroy

  scope :span_previous_month,
    -> { where('checkin_date BETWEEN ? AND ?', 1.month.ago.beginning_of_day, Date.today.end_of_day) }


  def self.submitted_checkins
    Checkin.last.user_checkins.map(&:user_id).uniq.count
  end

  def self.pending_checkins
    User.all.count - Checkin.submitted_checkins
  end

  def average_load
    user_count = self.tasks.map(&:user_id).uniq.count

    self.tasks.current.sum(:estimate) / user_count.to_f
  end

  def lowest_load
    tasks_per_user = self.tasks.current.group_by(&:user_id)

    task_load = []
    tasks_per_user.each_value do |tasks|
      task_load.push tasks.sum(&:estimate)
    end

    task_load.sort.first
  end

  def highest_load
    tasks_per_user = self.tasks.current.group_by(&:user_id)

    task_load = []
    tasks_per_user.each_value do |tasks|
      task_load.push tasks.sum(&:estimate)
    end

    task_load.sort.first
  end

end
