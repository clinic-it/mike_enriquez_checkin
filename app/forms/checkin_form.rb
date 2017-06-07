class CheckinForm < Reform::Form

  # properties :yesterday, :today, :virtual => true

  collection :yesterday, :virtual => true
  collection :today, :virtual => true

end
