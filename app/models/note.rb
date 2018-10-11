# == Schema Information
#
# Table name: notes
#
#  id                :integer          not null, primary key
#  checkin_id        :integer          not null
#  user_id           :integer          not null
#  description       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  message_timestamp :string
#

class Note < ApplicationRecord

  belongs_to :checkin
  belongs_to :user

end
