class CheckinsController < ApplicationController

  require 'csv'

  skip_before_action :authorize, :only => [:new]

  before_action :init, :only => [:index, :create, :destroy, :csv_checkin]
  after_action :generate_snapshot, :only => [:create, :csv_checkin]


  def index
    @checkins = Checkin.all.order(:checkin_date => :desc).page params[:page]
  end

  def show
    @checkin = Checkin.find_by_id params[:id]
  end

  def create
    @user = User.find_by_id current_user
    yesterday_tasks = array_string_to_hash params[:checkin][:yesterday]
    current_tasks = array_string_to_hash params[:checkin][:today]

    generate_attachments yesterday_tasks, false
    generate_attachments current_tasks, true
    generate_blockers params[:checkin][:blockers]
    generate_notes params[:checkin][:notes]


    redirect_to summary_path
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
            'Work on tasks'
          else
            "*Work on #{project.name}*"
          end
      )

      project_tasks = entry[1]

      project_tasks.each do |task|
        @all_tasks.push(
          new_task = Task.create(
            :checkin_id => @checkin.id,
            :project_id => project.nil? ? 100000 : project.id,
            :user_id => @user.id,
            :title => task[:title],
            :url => task[:url],
            :current_state => task[:current_state],
            :estimate => task[:estimate],
            :task_type => task[:task_type],
            :current => current_tasks,
            :task_id => task[:task_id]
          )
        )

        display_estimate = (task[:estimate] == nil) ? 'Unestimated' : task[:estimate]
        times_checkedin = new_task.current ? "[Times checked in: #{new_task.times_checked_in_current}]" : ''

        fields.push(
          :value => "<#{task[:url]}|•[#{task[:task_type]}][#{task[:current_state]}][#{display_estimate}]#{times_checkedin} #{task[:title]}>"
        )

        estimate += task[:estimate].to_i
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
    return if blockers.blank?

    @blocker = Blocker.create(
      :checkin_id => @checkin.id,
      :user_id => @user.id,
      :description => blockers
    )
  end

  def generate_notes notes
    return if notes.blank?

    @note = Note.create(
      :checkin_id => @checkin.id,
      :user_id => @user.id,
      :description => notes
    )
  end

  def update_message_timestamp tasks
    @timestamp = @client.chat_postMessage(@message_format).ts

    tasks.each do |task|
      task.update_attributes :message_timestamp => @timestamp
    end

    @user_checkin.update_attributes :message_timestamp => @timestamp
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

  def generate_task_blockers task, new_task
    blocker_texts = []
    blocker_statuses = []
    blockers = []

    task.each do |row|
      blocker_texts.push row[1] if row[0] == 'Blocker'
    end

    task.each do |row|
      blocker_statuses.push row[1] if row[0] == 'Blocker Status'
    end

    (0..blocker_texts.count).each do |i|
      blockers.push blocker_texts[i] unless blocker_texts[i] == nil
    end

    blockers.each do |blocker|
      TaskBlocker.create :task => new_task, :blocker_text => blocker
    end
  end



  private

  def init
    channel_hash = {
      'bot-test' => 'C1D6U9RQC',
      'checkins' => 'C13M4L95W'
    }

    @user = User.find_by_id current_user
    @checkin = Checkin.find_or_create_by :checkin_date => Date.today
    @client = Slack::Web::Client.new
    @channel = channel_hash[ENV['channel']]
    @current_date = Date.today
    @yesterday_date = @current_date.monday? ? (@current_date - 3) : Date.yesterday
    @all_tasks = []

    check_for_existing_daily_user_checkin
  end

  def generate_snapshot
    filename = "#{@user.username}_#{@checkin.checkin_date}"
    save_path = Rails.root.join 'tmp', filename

    action_controller_instance = ActionController::Base.new.tap { |controller|
      def controller.params
        {:format => 'pdf'}
      end
    }

    pdf = WickedPdf.new.pdf_from_string(
      action_controller_instance.render_to_string(
        :action => 'create',
        :template => 'checkins/user_checkin',
        :layout => 'layouts/generated_pdf',
        :locals => { :@checkin => @checkin, :user => @user }
      ),
      :viewport_size => '1280x1024',
    )

    save_path = Rails.root.join 'tmp/', filename

    File.open(save_path, 'wb') do |file|
      file << pdf
    end

    original_pdf = File.open(save_path, 'rb').read

    image = Magick::Image::from_blob(original_pdf) do
      self.format = 'PDF'
      self.quality = 100
      self.density = 144
    end
    image[0].format = 'JPG'
    image[0].to_blob

    image[0].trim!.write(save_path)

    s3 = Aws::S3::Resource.new(region: ENV['region'], access_key_id: ENV['access_key_id'], secret_access_key: ENV['secret_access_key'])
    obj = s3.bucket(ENV['bucketname']).object("#{ENV['folder']}/#{filename}_#{DateTime.now.strftime('%N')}")
    obj.upload_file(save_path)

    @user_checkin = UserCheckin.find_or_create_by :user => @user, :checkin => @checkin
    @user_checkin.screenshot_path = obj.public_url
    @user_checkin.message_timestamp = @timestamp
    @user_checkin.save

    send_slack_message
  end

  def send_slack_message
    @message_format = {
      :channel => @channel,
      :as_user => true,
      :text => "*#{@user.username} filed his daily checkin.*",
      :attachments => [
        :title => Date.today.strftime('%B %d, %Y'),
        :image_url => @user_checkin.screenshot_path,
        :color => '#36a64f'
      ]
    }

    self.update_message_timestamp @all_tasks
  end

  def check_for_existing_daily_user_checkin
    checkin_tasks_to_override = Task.where :user => @user, :checkin => @checkin
    checkin_blockers_to_override =
      Blocker.where :user => @user, :checkin => @checkin
    checkin_notes_to_override =
      Note.where :user => @user, :checkin => @checkin

    if checkin_tasks_to_override.present?
      timestamps = checkin_tasks_to_override.map &:message_timestamp

      timestamps.uniq.each do |stamp|
        @message_format = {
          :channel => @channel,
          :ts => stamp
        }

        @client.chat_delete(@message_format) rescue next
      end

      checkin_tasks_to_override.destroy_all
    end

    checkin_blockers_to_override.destroy_all if checkin_blockers_to_override.present?
    checkin_notes_to_override.destroy_all if checkin_notes_to_override.present?
  end

  def array_string_to_hash array
    tasks = array.reject{|task| task == "0"}.map{|task| eval task}
    project_ids = tasks.map{|entry| entry[:project_id]}.uniq

    return_value = []
    project_ids.each do |project_id|
      return_value.push(
        [
          project_id,
          tasks.select{|entry| entry[:project_id] == project_id}
        ]
      )

    end

    return_value
  end

end
