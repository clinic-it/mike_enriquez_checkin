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

  def table_row_class type
    if type == 'feature'
      'table-success'
    elsif type == 'bug'
      'table-danger'
    else
      'table-active'
    end
  end

  def project_name_to_id project_name
    project_name.delete(' ').delete('&').delete '.'
  end

end
