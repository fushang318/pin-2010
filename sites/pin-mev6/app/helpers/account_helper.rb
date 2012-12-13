module AccountHelper


  def account_setting_link(name,url,klass)
    selected = current_page?(url)

    outer_klass = ['link',klass,selected ? 'selected':'']*' '
    
    link_str = link_to url do
      content_tag(:div, '', :class=>'icon') +
      content_tag(:span, name)
    end

    return content_tag(:div, link_str, :class=>outer_klass)
  end

end
