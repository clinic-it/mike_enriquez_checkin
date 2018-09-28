# == Schema Information
#
# Table name: task_blockers
#
#  id           :integer          not null, primary key
#  task_id      :integer
#  blocker_text :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class TaskBlocker < ActiveRecord::Base

  belongs_to :task
  
end
