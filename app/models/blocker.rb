# == Schema Information
#
# Table name: blockers
#
#  id                :integer          not null, primary key
#  checkin_id        :integer          not null
#  user_id           :integer          not null
#  description       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  message_timestamp :string
#

class Blocker < ApplicationRecord

  belongs_to :user
  belongs_to :checkin

end
