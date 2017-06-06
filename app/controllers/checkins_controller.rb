class CheckinsController < ApplicationController

  require 'csv'

  before_action :init, :only => [:index, :create, :destroy]
  after_action :generate_snapshot, :only => [:create]


  def index
    @checkins = Checkin.all.order(:checkin_date => :desc).page params[:page]
  end

  def show
    @checkin = Checkin.find_by_id params[:id]
  end

  def create
    @yesterday_tasks = params[:yesterday_tasks]
    @current_tasks = params[:current_tasks]
    @current_date = Date.today
    @yesterday_date = @current_date.monday? ? (@current_date - 3) : Date.yesterday
    @all_tasks = []

    yesterday_tasks = CSV.read(@yesterday_tasks.path, :headers => true).group_by{|task| task['Project Id']}
    current_tasks = CSV.read(@current_tasks.path, :headers => true).group_by{|task| task['Project Id']}

    @message_format = {
      :channel => @channel,
      :as_user => true,
      :text => "*#{@user.username} filed his daily checkin.*",
      :attachments => [
        generate_attachments(yesterday_tasks, false),
        generate_attachments(current_tasks, true),
        generate_blockers(params[:blockers]),
        generate_notes(params[:notes])
      ]
    }


    self.update_message_timestamp @all_tasks

    redirect_to :root
  end


  def destroy
    timestamp = self.parse_timestamp params[:timestamp]

    @message_format = {
      :channel => @channel,
      :ts => timestamp
    }

    self.destroy_tasks_from_checkin

    redirect_to :root
  end



  protected

  def parse_timestamp ts
    ts.tr('p', '').insert 10 ,'.'
  end

  def generate_attachments arr, current_tasks
    estimate = 0
    fields = []

    pretext =
      if current_tasks
        @current_date.strftime "Current Tasks (%A - %m/%d/%Y)"
      else
        @yesterday_date.strftime "Yesterday's Tasks (%A - %m/%d/%Y)"
      end

    arr.each do |entry|
      project = Project.find_by_pivotal_id entry[0].to_i

      fields.push(
        :value =>
          if project.nil?
            file_to_process = current_tasks ? @yesterday_tasks.original_filename : @current_tasks.original_filename
            "*Work on #{file_to_process.split('_')[0]}*"
          else
            "*Work on #{project.name}*"
          end
      )

      project_tasks = entry[1]

      project_tasks.each do |task|
        task_owners = []

        task.each do |field|
          task_owners.push field.last if field.first == 'Owned By'
        end

        if task_owners.include? @user.fullname
          @all_tasks.push(
            new_task = Task.create(
              :checkin_id => @checkin.id,
              :project_id => project.nil? ? 100000 : project.id,
              :user_id => @user.id,
              :title => task['Title'],
              :url => task['URL'],
              :current_state => task['Current State'],
              :estimate => task['Estimate'],
              :task_type => task['Type'],
              :current => current_tasks,
              :task_id => task['Id']
            )
          )

          display_estimate = (task['Estimate'] == nil) ? 'Unestimated' : task['Estimate']
          times_checkedin = new_task.current ? "[Times checked in: #{new_task.times_checked_in_current}]" : ''

          fields.push(
            :value => "<#{task['URL']}|•[#{task['Type']}][#{task['Current State']}][#{display_estimate}]#{times_checkedin} #{task['Title']}>"
          )

          estimate += task['Estimate'].to_i
        end
      end

    end

    fields.push(
      {
        :title => "Load: #{estimate}"
      }
    )

    return(
      {
        :pretext => pretext,
        :fields => fields,
        :color => '#36a64f',
        :mrkdwn_in => ['fields']
      }
    )
  end

  def generate_blockers blockers
    return if blockers.empty?

    @blocker = Blocker.create(
      :checkin_id => @checkin.id,
      :user_id => @user.id,
      :description => blockers
    )


    fields = []

    fields.push(
      {
        :title => 'Blockers',
        :value => blockers
      }
    )

    return(
      {
        :fields => fields,
        :color => '#ff0000',
        :mrkdwn_in => ['fields']
      }
    )
  end

  def generate_notes notes
    return if notes.empty?

    @note = Note.create(
      :checkin_id => @checkin.id,
      :user_id => @user.id,
      :description => notes
    )

    fields = []

    fields.push(
      {
        :title => 'Notes',
        :value => notes
      }
    )

    return(
      {
        :fields => fields,
        :color => '#0000ff',
        :mrkdwn_in => ['fields']
      }
    )
  end

  def update_message_timestamp tasks
    @timestamp = @client.chat_postMessage(@message_format).ts

    tasks.each do |task|
      task.update_attributes :message_timestamp => @timestamp
    end

    @blocker.update_attributes :message_timestamp => @timestamp if @blocker
    @note.update_attributes :message_timestamp => @timestamp if @note
  end

  def destroy_tasks_from_checkin
    timestamp = @client.chat_delete(@message_format).ts

    tasks = Task.where :message_timestamp => timestamp
    tasks.destroy_all

    blocker = Blocker.where(:message_timestamp => timestamp).try :destroy_all
    note = Note.where(:message_timestamp => timestamp).try :destroy_all
    user_checkin =
      UserCheckin.where(:message_timestamp => timestamp).try :destroy_all
  end



  private

  def init
    channel_hash = {
      'bot-test' => 'C1D6U9RQC',
      'checkins' => 'C13M4L95W'
    }

    @user = User.find_by_id params[:id]
    @checkin = Checkin.find_or_create_by :checkin_date => Date.today
    @client = Slack::Web::Client.new
    @channel = channel_hash[ENV['channel']]
  end

  def generate_snapshot
    kit = IMGKit.new render_to_string(:partial => 'checkins/user_checkin', :locals => {:@checkin => @checkin, :user => @user})
    filename = "#{@user.username}_#{@checkin.checkin_date}"
    save_path = Rails.root.join 'tmp', filename

    File.open(save_path, 'wb') do |file|
      file << kit.to_img(:jpg)
    end

    s3 = Aws::S3::Resource.new(region: ENV['region'], access_key_id: ENV['access_key_id'], secret_access_key: ENV['secret_access_key'])
    obj = s3.bucket(ENV['bucketname']).object("#{ENV['folder']}/#{filename}")
    obj.upload_file(save_path)

    user_checkin = UserCheckin.find_or_create_by :user => @user, :checkin => @checkin
    user_checkin.screenshot_path = obj.public_url
    user_checkin.message_timestamp = @timestamp
    user_checkin.save
  end

end
