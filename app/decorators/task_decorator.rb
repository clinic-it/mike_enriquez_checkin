class TaskDecorator < ApplicationDecorator

  def estimate
    (task.estimate == 0) ? 'Unestimated' : task.estimate
  end

  def times_checkedin
    task.current ? "[Times checked in: #{task.times_checked_in_current}]" : ''
  end

  def to_s
    "[#{self.task_type}][#{self.current_state}][#{self.estimate}]#{self.times_checkedin} #{self.title}"
  end
  
end
