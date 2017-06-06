class CheckinForm < Reform::Form

  # properties :yesterday, :today, :virtual => true

  collection :yesterday, :virtual => true

end
