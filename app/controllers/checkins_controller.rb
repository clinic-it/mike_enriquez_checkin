class CheckinsController < ApplicationController

  require 'csv'

  before_action :init, :only => [:index, :create, :destroy]
  after_action :generate_snapshot, :only => [:create]


  def index
    @checkins = Checkin.all.order(:checkin_date => :desc).page params[:page]
  end

  def show
    @checkin = Checkin.find_by_id params[:id]

    respond_to do |format|
      format.html
      format.jpg do
        @kit = IMGKit.new(render_to_string)
        send_data(@kit.to_jpg, :type => 'image/jpeg', :disposition => 'inline')
      end
    end
  end

  def create
    @current_tasks = params[:current_tasks]
    @upcoming_tasks = params[:upcoming_tasks]
    @current_date = Date.today
    @upcoming_date = @current_date.friday? ? (@current_date + 3) : Date.tomorrow
    @all_tasks = []

    current_tasks = CSV.read(@current_tasks.path, :headers => true).group_by{|task| task['Project Id']}
    upcoming_tasks = CSV.read(@upcoming_tasks.path, :headers => true).group_by{|task| task['Project Id']}

    message_format = {
      :channel => @channel,
      :as_user => true,
      :text => "*#{@user.username} filed his daily checkin.*",
      :attachments => [
        generate_attachments(current_tasks, true),
        generate_attachments(upcoming_tasks, false),
        generate_blockers(params[:blockers]),
        generate_notes(params[:notes])
      ]
    }

    posted_checkin = @client.chat_postMessage message_format

    self.update_message_timestamp @all_tasks, posted_checkin.ts

    redirect_to :root
  end


  def destroy
    timestamp = self.parse_timestamp params[:timestamp]

    message_format = {
      :channel => @channel,
      :ts => timestamp
    }

    deleted_checkin = @client.chat_delete message_format

    self.destroy_tasks_from_checkin deleted_checkin.ts

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
        @current_date.strftime "What I've worked on (%A - %m/%d/%Y)"
      else
        @upcoming_date.strftime "What I'm going to do (%A - %m/%d/%Y)"
      end

    arr.each do |entry|
      project = Project.find_by_pivotal_id entry[0].to_i

      fields.push(
        :value =>
          if project.nil?
            file_to_process = current_tasks ? @current_tasks.original_filename : @upcoming_tasks.original_filename
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
            Task.create(
              :checkin_id => @checkin.id,
              :project_id => project.nil? ? 100000 : project.id,
              :user_id => @user.id,
              :title => task['Title'],
              :url => task['URL'],
              :current_state => task['Current State'],
              :estimate => task['Estimate'],
              :task_type => task['Type'],
              :current => current_tasks
            )
          )

          display_estimate = (task['Estimate'] == nil) ? 'Unestimated' : task['Estimate']

          fields.push(
            :value => "<#{task['URL']}|•[#{task['Type']}][#{task['Current State']}][#{display_estimate}] #{task['Title']}>"
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

    Blocker.create(
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

    Note.create(
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

  def update_message_timestamp tasks, timestamp
    tasks.each do |task|
      task.update_attributes :message_timestamp => timestamp
    end
  end

  def destroy_tasks_from_checkin timestamp
    tasks = Task.where :message_timestamp => timestamp
    tasks.destroy_all
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
    obj = s3.bucket(ENV['bucketname']).object(filename)
    obj.upload_file("tmp/#{filename}")

    user_checkin = UserCheckin.find_or_create_by :user => @user, :checkin => @checkin
    user_checkin.screenshot_path = obj.public_url
    user_checkin.save
  end

end
