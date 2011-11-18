module ApplicationMethods
  def self.included(base)
    # 拦截ie6的访问
    base.before_filter :hold_ie6
    # 捕捉一些特定异常
    base.around_filter :catch_some_exception


    base.before_filter :change_user_name_when_need_change_name
    # 通过插件开启gzip压缩
    base.after_filter OutputCompressionFilter
    # 修正IE浏览器请求头问题
    base.before_filter :fix_ie_accept
    # 对错误显示友好的页面
    base.around_filter :catch_template_exception
    # 强制信息不完整的用户补充信息
    base.before_filter :force_to_complete
  end

  #-----------------------
  
  def render_status_page(code, text = '')
    flash.now[:status_text] = text
    flash.now[:status_code] = code
    render "layouts/status_page/status_page",:status=>code
  end

  #----------------------

  def hold_ie6
    if /MSIE 6.0/.match(request.user_agent)
      render "layouts/status_page/hold_ie6",:layout=>false
    end
  end

  def set_client_cache_key
    if cookies[CLIENT_CACHE_KEY].blank?
      cookies[CLIENT_CACHE_KEY] = {:value=>randstr,:expires => 30.days.from_now,:domain=>'mindpin.com'}
    end
  end

  def catch_some_exception
    yield
  rescue MemCache::MemCacheError
    render_status_page(500,"缓存服务出现异常，请尝试刷新页面。")
  rescue ActiveRecord::RecordNotFound
    render_status_page(404,"正在访问的页面不存在，或者已被删除。")
  rescue Exception => e
    if RAILS_ENV == 'production'
      return render_status_page(500,e.message)
    else
      raise e
    end
  end

  def change_user_name_when_need_change_name
    if current_user
      current_user.change_name_when_need!
    end
  end

  def fix_ie_accept
    if /MSIE/.match(request.user_agent) && request.env["HTTP_ACCEPT"]!='*/*'
      if !/.*\.gif/.match(request.url)
        request.env["HTTP_ACCEPT"] = '*/*'
      end
    end
  end

  def catch_template_exception
    yield
  rescue ActionView::TemplateError=>ex
    if RAILS_ENV == "development"
      raise ex
    else
      return render_status_page(500,ex.message)
    end
  end

  def is_android_client?
    request.headers["User-Agent"] == "android"
  end

  def force_to_complete
    return true if [
      ["account/complete", "index"  ],
      ["account/complete", "submit" ],
      ["sessions"        , "destroy"],
    ].include? [params[:controller], params[:action]]

    if logged_in? && current_user.is_user_info_incomplete?
      redirect_to pin_url_for("pin-user-auth","/account/complete")
    end
  end

end
