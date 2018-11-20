task :send_weekly_summary => :environment do

  # next unless Date.today.strftime('%A') == 'Friday'

  START_OF_THE_WEEK = Date.today.at_beginning_of_week.strftime '%Y-%m-%d'
  END_OF_THE_WEEK = Date.tomorrow.strftime '%Y-%m-%d'

  tasks_completed = []

  User.all.each do |user|
    current_user =
      FreshBooks::Client.new(
        ENV['freshbooks_url'], user.freshbooks_token
      )

    staff = current_user.staff.current
    entries =
      current_user.time_entry.list(
        :per_page => 100,
        :date_from => START_OF_THE_WEEK,
        :date_to => END_OF_THE_WEEK
      )

    next if entries.to_s.include? 'Authentication failed'

    entries['time_entries']['time_entry'].each do |time_entry|
      project = current_user.project.get :project_id => time_entry['project_id']
      object = {
        :username => staff['staff']['username'],
        :project => project['project']['name'],
        :hours => time_entry['hours'],
        :date => time_entry['date'],
        :notes => time_entry['notes']
      }

      tasks_completed.push object
    end
  end

  tasks_completed.sort_by! { |record| record[:username] }

  WeeklySummaryMailer.send_weekly_summary(tasks_completed).deliver

end
