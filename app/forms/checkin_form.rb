class CheckinForm < Reform::Form

  properties :blockers, :notes, :virtual => true

  collection :yesterday, :virtual => true
  collection :today, :virtual => true

end
