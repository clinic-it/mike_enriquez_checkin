class DashboardsController < ApplicationController

  def index
    @checkin = CheckinForm.new Checkin.last
    @pivotal = TrackerApi::Client.new(token: '0dbcbec6e4625e965dbdf5444dcb929d')
  end

end
