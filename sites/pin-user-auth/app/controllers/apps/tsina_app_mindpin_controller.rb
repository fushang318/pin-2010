class Apps::TsinaAppMindpinController < ApplicationController
  include ConnectTsinaControllerMethods
  
  def connect
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.app_mindpin_authorize_url
  end

  def callback
    deal_tsina_callback pin_url_for("pin-user-auth")
  end

end
