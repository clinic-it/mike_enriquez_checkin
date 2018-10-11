class UserForm < Reform::Form

  properties :username, :fullname, :password, :pivotal_token, :pivotal_owner_id,
    :admin, :active, :freshbooks_token, :freshbooks_task_id, :image

  validates_uniqueness_of :username, :message => 'already exists.'

  validates :username, :fullname, :password, :pivotal_token, :pivotal_owner_id,
    :freshbooks_token, :freshbooks_task_id, :presence => true



  def save
    self.username.downcase!

    super

    attach_image
  end




  private

  def attach_image
    self.model.image.attach self.image
  end

end
