# == Schema Information
#
# Table name: user_checkins
#
#  id                :integer          not null, primary key
#  checkin_id        :integer
#  user_id           :integer
#  screenshot_path   :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  message_timestamp :string
#

class UserCheckin < ApplicationRecord

  belongs_to :user
  belongs_to :checkin

end
