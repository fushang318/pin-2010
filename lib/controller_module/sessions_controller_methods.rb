module SessionsControllerMethods
  def self.included(base)
    # 登录表单不进行csrf校验
    base.skip_before_filter :verify_authenticity_token
  end

  # 登录
  def new
    if logged_in?
      return redirect_back_or_default(root_url)
    end

    render :layout=>'anonymous',:template=>'index/login'
  end

  def create
    self.current_user = User.authenticate(params[:email],params[:password])

    if logged_in?
      after_logged_in()
    else
      flash[:error]="邮箱/密码不正确"
    end
    
    _redirect_by_service
  end

  # 登出
  def destroy
    user = current_user

    if user
      reset_session_with_online_key()
      # 登出时销毁cookies令牌
      destroy_remember_me_cookie_token()
      destroy_online_record(user)
    end

    _redirect_by_service
  end

  private
  def _redirect_by_service
    if params[:service] == "tu"
      return redirect_back_or_default(pin_url_for("pin-daotu"))
    else
      return redirect_back_or_default(root_url)
    end
  end

end