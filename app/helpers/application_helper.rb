module ApplicationHelper

  def icon_tag value, options = nil
    if value == 0
      klass = 'minus'
    elsif value > 0
      klass = 'caret-up'
    else
      klass = 'caret-down'
    end

    options ||= {}
    options[:class] ||= ''
    options[:class] << " fa fa-#{klass} fa-2x"

    content_tag :i, nil, options
  end

end
