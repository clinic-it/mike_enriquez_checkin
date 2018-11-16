# == Schema Information
#
# Table name: completed_tasks
#
#  id            :bigint(8)        not null, primary key
#  project_title :string
#  story_title   :string
#  estimate      :float
#  occured       :datetime
#  user_id       :bigint(8)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class CompletedTaskTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
