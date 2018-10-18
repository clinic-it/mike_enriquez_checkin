class UserForm < Reform::Form

  properties :username, :fullname, :password, :pivotal_token, :pivotal_owner_id,
    :admin, :active, :freshbooks_token, :freshbooks_task_id, :image_url

  property :image, :virtual => true

  validates_uniqueness_of :username, :message => 'already exists.'

  validates :username, :fullname, :pivotal_owner_id, :freshbooks_task_id,
    :presence => true

  validate :password, :if => :check_password

  validate :pivotal_token, :if => :validate_pivotal_token

  validate :freshbooks_token, :if => :validate_freshbooks_token



  def save
    self.username.downcase!
    self.image_url = upload_image if self.image.present?

    super
  end




  private

  def upload_image
    s3 =
      Aws::S3::Resource.new(
        :region => ENV['region'],
        :access_key_id => ENV['access_key_id'],
        :secret_access_key => ENV['secret_access_key']
      )
    object =
      s3.
      bucket(ENV['bucketname']).
      object [
          ENV['folder'], 'avatars',
          "#{self.username}.#{self.image.tempfile.to_path.split('.').last}"
        ].join '/'

    object.upload_file self.image.tempfile

    object.public_url
  end


  def check_password
    unless self.password.present?
      errors.add :password, ' missing. Please enter the password to continue.'
    end
  end


  def validate_pivotal_token
    response = PivotalRequest.request 'https://www.pivotaltracker.com/services/v5/projects', 'get', self.pivotal_token

    if response.include? 'invalid_authentication'
      errors.add :pivotal_token, " is invalid. #{JSON.parse(response)['possible_fix']}"
    end
  end


  def validate_freshbooks_token
    user =
      FreshBooks::Client.new(
        ENV['freshbooks_url'], self.freshbooks_token
      )

    response = user.task.list :per_page => 100

    if response.to_s.include? 'Authentication failed'
      errors.add :freshbooks_token, "is invalid. #{response['error']}"
    end
  end

end
