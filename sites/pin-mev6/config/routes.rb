Mindpin::Application.routes.draw do
  # -- 从 user-auth 迁移的
  post '/login'  => 'sessions#create'
  get  '/logout' => 'sessions#destroy'

  get  '/signup'        => 'signup#form'
  post '/signup_submit' => 'signup#form_submit'

  # 基本信息
  get  "/account"                     => "setting#base"
  put  "/account"                     => "setting#base_submit"

  # 头像设置
  get  "/account/avatared"               => 'setting#avatared'
  post "/account/avatared_submit_raw"    => 'setting#avatared_submit_raw'
  post "/account/avatared_submit_copper" => 'setting#avatared_submit_copper'
  
  # -- 忘记密码 --
  get  'forgot_password'                => 'forgot_password#form'
  post 'forgot_password/submit'         => 'forgot_password#form_submit'
  get  'reset_password/:pw_code'        => 'forgot_password#reset'
  put  'reset_password_submit/:pw_code' => 'forgot_password#reset_submit'
  # ---------------- 首页和欢迎页面 ---------
  root :to => 'index#index'
  get '/login' => 'index#index'
  
  get '/publics' => 'index#public_maps'
  get '/favs'    => 'index#fav_maps'
  
  get '/search'  => 'search#index'

  resources :users
  resources :image_attachments

  post '/create' => 'builder#create'  # 普通创建
  post '/import' => 'builder#import'  # 导入

  put '/v6/save'             => 'v6/editor#save'
  get '/v6/:mindmap_id'      => 'v6/editor#index'
  get '/v6/:mindmap_id/edit' => 'v6/editor#edit'
  get '/v6/:mindmap_id/view' => 'v6/editor#view'
  
  put '/v7/save'             => 'v7/editor#save'
  get '/v7/:mindmap_id'      => 'v7/editor#index'
  get '/v7/:mindmap_id/edit' => 'v7/editor#edit'
  get '/v7/:mindmap_id/view' => 'v7/editor#view'

  resources :mindmaps do
    member do
      put :toggle_private
      get :info
      put :toggle_fav
      put :undo
      put :redo
      put :refresh_thumb
    end
    get 'files'              => 'files#index'
    get 'files/search_image' => 'files#search_image'
    get 'files/i_editor'     => 'files#show_image_editor'
    get 'files/f_editor'     => 'files#show_font_editor'
  end

  # others...
  get '/about' => 'help#about'
  
  # 导图相册
  resources :albums do
    member do
      put :toggle_private
      post :movein
    end
    collection do
      post :moveout
    end
  end

end
