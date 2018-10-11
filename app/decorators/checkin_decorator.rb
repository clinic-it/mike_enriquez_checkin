class CheckinDecorator < ApplicationDecorator
  delegate_all


  def formatted_date
    object.checkin_date.strftime '%B %d, %Y'
  end

end
