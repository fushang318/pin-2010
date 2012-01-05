require 'rack/utils'

class FlashSessionCookieMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      req = Rack::Request.new(env)

      session_key   = Mindpin::Application.config.session_options[:key]
      session_value = req.params[session_key]
      
      http_accept   = req.params['_http_accept']

      env['HTTP_COOKIE'] = [session_key, session_value].join('=').freeze if !session_value.blank?
      env['HTTP_ACCEPT'] = "#{http_accept}".freeze if !http_accept.blank?
    end
    @app.call(env)
  end
end

Rails.application.config.middleware.insert_before(
  ActionDispatch::Session::CookieStore,
  FlashSessionCookieMiddleware
)
