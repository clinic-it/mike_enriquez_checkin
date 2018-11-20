class CompletedTask

  attr_reader :username, :project, :hours, :date, :notes



  def initialize staff, time_entry, project
    @username = staff['staff']['username']
    @project = project['project']['name']
    @hours = time_entry['hours']
    @date = time_entry['date']
    @notes = time_entry['notes']
  end

end
