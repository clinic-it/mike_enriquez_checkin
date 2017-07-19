class User < ActiveRecord::Base

  has_secure_password

  has_many :checkins
  has_many :blockers
  has_many :tasks
  has_many :user_checkins

  def tasks_by_week
    self.tasks.group_by &:week
  end

  def current_load
    Checkin.last.tasks.current.where(:user => self).sum(:estimate)
  end

  def previous_load
    Checkin.offset(1).last.tasks.current.where(:user => self).sum(:estimate)
  end

  def is_admin?
    self.admin
  end

end
