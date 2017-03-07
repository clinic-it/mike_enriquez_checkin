class CheckinsController < ApplicationController
  require 'csv'

  before_action :init, :only => [:index, :create, :destroy]


  def index
    @sss = @client.channels_list
  end

  def create
    @project_hash = {
      1874223 => 'Ernesto',
      1978467 => 'General R&D',
      1149382 => 'LSD-JB',
      1977673 => 'FlightBot',
      1435852 => 'LSD-LG',
      97426 => 'LSD-BT',
      1435854 => 'LSD-MAT',
      1149370 => 'LSD-MBC',
      1876729 => 'Amanda',
      1143948 => 'Effie',
      811717 => 'DOCD'
    }

    @user = User.find_by_id params[:id]
    @current_tasks = params[:current_tasks]
    @upcoming_tasks = params[:upcoming_tasks]
    @current_date = Date.today
    @upcoming_date = @current_date.friday? ? (@current_date + 3) : Date.tomorrow

    current_tasks = CSV.read(@current_tasks.path, :headers => true).group_by{|task| task['Project Id']}
    upcoming_tasks = CSV.read(@upcoming_tasks.path, :headers => true).group_by{|task| task['Project Id']}

    message_format = {
      :channel => @channel,
      :as_user => true,
      :text => "*#{@user.username} filed his daily checkin.*",
      :attachments => [
        generate_attachments(current_tasks, true),
        generate_attachments(upcoming_tasks, false),
        generate_blockers(params[:blockers])
      ]
    }

    @client.chat_postMessage message_format

    redirect_to :root
  end


  def destroy
    timestamp = self.parse_timestamp params[:timestamp]

    message_format = {
      :channel => @channel,
      :ts => timestamp
    }

    @client.chat_delete message_format

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

      fields.push(
        :value =>
          if entry[0].nil?
            file_to_process = current_tasks ? @current_tasks.original_filename : @upcoming_tasks.original_filename
            "*Work on #{file_to_process.split('_')[0]}*"
          else
            "*Work on #{@project_hash[entry[0].to_i]}*"
          end
      )

      project_tasks = entry[1]

      project_tasks.each do |task|
        fields.push(
          :value => "<#{task['URL']}|•[#{task['Type']}][#{task['Current State']}][#{task['Estimate']}] #{task['Title']}>"
        )

        estimate += task['Estimate'].to_i
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



  private

  def init
    channel_hash = {
      'bot-test' => 'C1D6U9RQC',
      'checkins' => 'C13M4L95W'
    }

    @client = Slack::Web::Client.new
    @channel = channel_hash[ENV['channel']]
  end
end
