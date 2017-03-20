class CheckinForm < Reform::Form

  property :today, :virtual => true
  property :tomorrow, :virtual => true

end
