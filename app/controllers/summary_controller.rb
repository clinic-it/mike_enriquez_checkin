class SummaryController < ApplicationController
  def show
    @today = Checkin.last
    @yesterday = Checkin.offset(1).last

    @chart_data = [
      {:name => 'Yesterday', :data => @yesterday.users_with_checkin.map{|user| [user.username, user.previous_load]} },
      {:name => 'Today', :data => @today.users_with_checkin.map{|user| [user.username, user.current_load]} }
    ]
  end
end
