class User < ActiveRecord::Base

  has_many :checkins
  has_many :blockers
  has_many :tasks

  def tasks_by_week
    self.tasks.group_by &:week
  end

end
