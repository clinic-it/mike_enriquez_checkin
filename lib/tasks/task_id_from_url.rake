task :fill_task_id => :environment do
  Task.all.each do |task|
    task.task_id = task.url.split('/').last
    task.save
  end
end
