class CheckinsController < ApplicationController

  skip_before_action :authorize, :only => [:new]

  before_action :init, :only => [:index, :create, :destroy]
  after_action :generate_snapshot, :only => [:create]


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

    generate_tasks yesterday_tasks, false
    generate_tasks current_tasks, true
    generate_attachments params[:checkin][:blockers], 'blocker'
    generate_attachments params[:checkin][:notes], 'note'


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

  def generate_tasks arr, current_tasks
    arr.each do |entry|
      project = Project.find_by_pivotal_id entry[0].to_i

      if project.nil?
        @pivotal = TrackerApi::Client.new :token =>  @user.pivotal_token

        temp_project = @pivotal.project entry[0].to_i

        project =
          Project.create(
            :name => temp_project.name,
            :pivotal_id => entry[0].to_i
          )
      end

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

        params = {
          :token => @user.pivotal_token,
          :project_id => project.pivotal_id,
          :story_id => task[:task_id]
        }

        generate_blockers new_task, params
      end

    end
  end

  def generate_attachments description, klass
    return if description.blank?

    instance_variable_set("@#{klass}", klass.humanize.constantize.create(
      :checkin_id => @checkin.id,
      :user_id => @user.id,
      :description => description
    ))
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

    Blocker.where(:message_timestamp => timestamp).try :destroy_all
    Note.where(:message_timestamp => timestamp).try :destroy_all
    UserCheckin.where(:message_timestamp => timestamp).try :destroy_all
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

    obj = generate_image original_pdf, save_path, filename

    @user_checkin = UserCheckin.find_or_create_by :user => @user, :checkin => @checkin
    @user_checkin.screenshot_path = obj.public_url
    @user_checkin.message_timestamp = @timestamp
    @user_checkin.save

    send_slack_message
  end

  def generate_image pdf, save_path, filename
    image = Magick::Image::from_blob(pdf) do
      self.format = 'PDF'
      self.quality = 100
      self.density = 144
    end
    image[0].format = 'JPG'
    image[0].to_blob
    image[0].trim!.write save_path

    s3 = Aws::S3::Resource.new(region: ENV['region'], access_key_id: ENV['access_key_id'], secret_access_key: ENV['secret_access_key'])
    obj = s3.bucket(ENV['bucketname']).object("#{ENV['folder']}/#{filename}_#{DateTime.now.strftime('%N')}")
    obj.upload_file save_path

    obj
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
      timestamps = checkin_tasks_to_override.map(&:message_timestamp)

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

  def generate_blockers new_task, params
    blockers = PivotalBlocker.new(params).blockers

    if blockers.present?
      blockers.each do |blocker|
        unless blocker['resolved']
          TaskBlocker.create(
            :task_id => new_task.id,
            :blocker_text => blocker['description']
          )
        end
      end
    end
  end

end
