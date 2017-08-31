class UsersController < ApplicationController

  def show
    @user = User.find_by_id params[:id]
    @current_daily =
      @user.
        tasks.current_tasks_1month_ago.
        group_by(&:checkin).reject{|entry| entry.nil?}.
        map{|checkin, tasks| ["#{checkin.checkin_date.strftime('%B %d, %Y')}", "#{tasks.sum{|task| task.estimate ? task.estimate : 0}}"]}

    @current =
      @user.tasks_by_week.
      sort_by{|week| week}.
      map{|week, tasks| ["#{Task.week_dates(week)}", "#{tasks.reject{|task| !task.current}.sum{|task| task.estimate ? task.estimate : 0}}"]}

  end

  def toggle_active
    user = User.find_by_id params[:id]

    if user && user.toggle!(:active)
      redirect_to user
    end
  end

end
