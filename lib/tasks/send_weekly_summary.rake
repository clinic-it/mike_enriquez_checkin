task :send_weekly_summary => :environment do

  PH_TIME_ZONE = 8.hours

  next unless (Time.now + PH_TIME_ZONE).strftime('%A') == 'Wednesday'

  tasks_completed = []

  User.active.each do |user|
    freshbook_user = FreshbookUser.new user.freshbooks_token

    next if freshbook_user.invalid_token || freshbook_user.no_record

    freshbook_user.time_entries.each do |time_entry|
      project = freshbook_user.project time_entry['project_id']

      tasks_completed.push(
        CompletedTask.new(freshbook_user.staff, time_entry, project)
      )
    end
  end

  tasks_completed.sort_by! { |record| record.username }

  WeeklySummaryMailer.send_weekly_summary(tasks_completed).deliver

end
