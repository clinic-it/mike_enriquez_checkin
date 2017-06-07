class SummaryController < ApplicationController
  def show
    @today = Checkin.last
    @yesterday = Checkin.offset(1).last
  end
end
