task :save_today_summary => :environment do
  User.all.each do |user|
    pivotal_token = user.pivotal_token
    pivotal_owner = user.pivotal_owner_id
    projects = PivotalRequest.get_projects_data pivotal_token

    JSON.parse(projects).each do |project|
      project_id = project['id']
      project_title = project['name']
      stories =
        PivotalRequest.get_project_stories_data(
          pivotal_owner, pivotal_token, project_id
        )

      JSON.parse(stories).each do |story|
        story_id = story['id']
        story_title = story['name']
        story_estimate = story['estimate']
        transitions =
          PivotalRequest.get_story_transitions(
            pivotal_token, project_id, story_id
          )

        JSON.parse(transitions).each do |transition|
          occured = transition['occurred_at']

          if transition['state'] == 'finished'
            completed_task =
              CompletedTask.where(
                :project_title => project_title,
                :story_title => story_title,
                :estimate => story_estimate,
                :user => user
              ).first_or_initialize

            completed_task.occured = occured

            completed_task.save!
          end

          print '.'
        end
      end
    end
  end

  puts 'done'
end
