class DashboardsController < ApplicationController

  def index
    @checkin = CheckinForm.new Checkin.new
    pivotal = TrackerApi::Client.new(token: '0dbcbec6e4625e965dbdf5444dcb929d')

    @projects = pivotal.projects
  end

end
