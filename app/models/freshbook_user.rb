class FreshbookUser

  attr_reader :user

  START_OF_THE_WEEK = Date.today.at_beginning_of_week.strftime '%Y-%m-%d'
  END_OF_THE_WEEK = Date.tomorrow.strftime '%Y-%m-%d'




  def initialize token
    @user = FreshBooks::Client.new ENV['freshbooks_url'], token
  end

  def staff
    @user.staff.current
  end

  def entries
    @user.time_entry.list(
      :per_page => 100,
      :date_from => START_OF_THE_WEEK,
      :date_to => END_OF_THE_WEEK
    )
  end

  def invalid_token
    self.entries.to_s.include? 'Authentication failed'
  end

  def no_record
    self.entries['time_entries']['total'] == '0'
  end

  def project project_id
    @user.project.get :project_id => project_id
  end

  def time_entries
    [self.entries['time_entries']['time_entry']].flatten
  end

end
