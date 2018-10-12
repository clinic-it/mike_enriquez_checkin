# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  username           :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  fullname           :string
#  password_digest    :string
#  pivotal_token      :string
#  pivotal_owner_id   :integer
#  admin              :boolean
#  active             :boolean          default(TRUE)
#  freshbooks_token   :string
#  freshbooks_task_id :string
#  image_url          :string
#

class User < ApplicationRecord

  has_secure_password

  has_many :checkins
  has_many :blockers
  has_many :tasks
  has_many :user_checkins



  def self.freshbooks_tasks current_user
    @user =
      FreshBooks::Client.new(
        'clinicdev.freshbooks.com', current_user.freshbooks_token
      )
    tasks = @user.task.list :per_page => 100
    tasks_data = []

    tasks['tasks']['task'].each do |task|
      tasks_data.push [task['name'], task['task_id']]
    end

    tasks_data
  end


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
