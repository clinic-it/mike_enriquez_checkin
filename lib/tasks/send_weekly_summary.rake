task :send_weekly_summary => :environment do
  WeeklySummaryMailer.send_weekly_summary.deliver
end
