class UserForm < Reform::Form

  properties :username, :fullname, :password, :pivotal_token, :pivotal_owner_id,
    :admin, :active, :freshbooks_token, :freshbooks_task_id, :image_url

  property :image, :virtual => true

  validates_uniqueness_of :username, :message => 'already exists.'

  validates :username, :fullname, :password, :pivotal_token, :pivotal_owner_id,
    :freshbooks_token, :freshbooks_task_id, :presence => true



  def save
    self.username.downcase!
    self.image_url = upload_image

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

end
