class UsersController < ApplicationController

  decorates_assigned :user, :users

  before_action :new_user, :only => [:index, :create]
  before_action :find_user, :only => [:edit, :update, :show]
  before_action :init_form, :only => [:index, :create, :edit, :update]



  def index
    @users = User.all
  end


  def create
    if @form.validate params[:user]
      @form.save

      flash[:notice] = 'Successfully created user.'
    else
      flash[:error] = @form.errors.full_messages
    end

    redirect_to users_path
  end


  def edit
    redirect_to edit_user_path current_user unless @user == current_user
  end


  def update
    if @form.validate params[:user]
      @form.save

      flash[:notice] = 'Successfully updated user.'
    else
      flash[:error] = @form.errors.full_messages
    end

    redirect_to edit_user_path current_user
  end


  def show
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




  private

  def new_user
    @user = User.new
  end


  def find_user
    @user = User.find params[:id]
  end


  def init_form
    @form = UserForm.new @user
  end

end
