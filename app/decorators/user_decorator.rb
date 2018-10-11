class UserDecorator < ApplicationDecorator

  def formatted_active
    object.active ? 'Active' : 'Inactive'
  end

  def toggle_active_text
    object.active ? 'Set as inactive' : 'Set as active'
  end

end
