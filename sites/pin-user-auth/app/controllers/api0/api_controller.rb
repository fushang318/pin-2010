class Api0::ApiController < ApplicationController
  before_filter :api0_need_login
  def api0_need_login
    return render :text=>'api0需要在登录状态下访问',:status=>401 if !logged_in?
  end

  # 手机客户端使用的数据同步方法
  def mobile_data_syn
    collections = current_user.created_collections_db
    return render :json=>{
      :user        => current_user.api0_json_hash,
      :collections => collections
    }
  end

  # 获取指定的收集册中的主题列表
  # :collection_id 必须  收集册的id
  # :since_id 非必须，若指定此参数，则只获取ID比since_id大的feed信息
  # :max_id 非必须，若指定此参数，则只获取ID小于或等于max_id的feed信息
  # :count 非必须 默认20，最大100，单页返回的结果条数
  # :page 非必须，返回结果的页码，默认1
  def collection_feeds
    collection = Collection.find(params[:collection_id])
    feeds = collection.feeds_limit({
      :since_id => params[:since_id],
      :max_id   => params[:max_id],
      :count    => params[:count],
      :page     => params[:page]
    })

    render :json=>feeds.map{|feed|
      api0_feed_json_hash(feed)
    }
  end
  
  # 根据id获取单条feed信息
  # :id 必须，feed的ID
  def show
    feed = Feed.find(params[:id])
    feed.save_viewed_by(current_user) if feed && current_user # 保存feed被用户查看过的记录
    
    render :json=>api0_feed_json_hash(feed)
  end

  # 获取当前用户以及其所有联系人的主题列表
  # :since_id 非必须，若指定此参数，则只获取ID比since_id大的feed信息
  # :max_id 非必须，若指定此参数，则只获取ID小于或等于max_id的feed信息
  # :count 非必须 默认20，最大100，单页返回的结果条数
  # :page 非必须，返回结果的页码，默认1
  def home_timeline
    feeds = current_user.home_timeline({
      :since_id => params[:since_id],
      :max_id   => params[:max_id],
      :count    => params[:count],
      :page     => params[:page]
    })

    render :json=>feeds.map{|feed|
      api0_feed_json_hash(feed)
    }
  end

  # 发送一个纯文字主题
  # :title 非必须
  # :detail 非必须
  # * 注：以上两个参数虽然都是非必须，但至少要有其中一个，否则400错误（请求参数错误）
  # :collection_ids 必须，一个到多个收集册的id，用英文逗号 ',' 隔开
  # :send_tsina 非必须，是否发送到新浪微博 取值为字符串的 true 或 false
  def create
    feed = Apiv0.send_feed_by_user(
      current_user,
      :title          => params[:title],
      :detail         => params[:detail],
      :collection_ids => params[:collection_ids],
      :send_tsina     => params[:send_tsina],
      :from           => Feed::FROM_ANDROID
    )

    render :json=>api0_feed_json_hash(feed)
  rescue Apiv0::ParamsNotValidException => e
    render :text=>"api0 参数错误：#{e.message}", :status=>400
  end

  
  # 上传一张图片
  # file 必须，binary二进制内容，上传的图片
  # * 注 此方法将返回photo name，该name在后续执行 send_with_photos 时将用到
  def upload_photo
    name = PhotoAdpater.create_by_upload_file(params[:file])
    render :json=>name
  end

  # :title 非必须
  # :detail 非必须
  # :photo_names 必须，一个到多个photo的name（从 upload_photo 方法返回结果中获得），用英文逗号 ',' 隔开
  # :collection_ids 必须，一个到多个收集册的id，用英文逗号 ',' 隔开
  # :send_tsina 非必须，是否发送到新浪微博 取值为字符串的 true 或 false
  # * 注 此方法从逻辑上来说应该在若干次调用 upload_photo 方法之后调用
  def create_with_photos
    feed = Apiv0.send_feed_by_user(
      current_user,
      :title          => params[:title],
      :detail         => params[:detail],
      :photo_names    => params[:photo_names],
      :collection_ids => params[:collection_ids],
      :send_tsina     => params[:send_tsina],
      :from           => Feed::FROM_ANDROID
    )

    render :json=>api0_feed_json_hash(feed)
  rescue Apiv0::ParamsNotValidException => e
    render :text=>"api0 参数错误：#{e.message}", :status=>400
  end

  # 创建一个收集册
  # :title 必须，收集册的标题
  def create_collection
    collection = current_user.create_collection_by_params(params[:title])

    unless collection.id.blank?
      render :json=>current_user.created_collections_db
    else
      render :text=>"api0 收集册创建失败",:status=>400
    end
  end

  # 删除一个收集册
  # :collection_id 必须  收集册的id
  def delete_collection
    collection = Collection.find(params[:collection_id])
    collection.destroy
    render :json=>current_user.created_collections_db
  end

  # 重命名一个收集册
  # :collection_id 必须  收集册的id
  # :title 必须，收集册的标题
  def rename_collection
    collection = Collection.find(params[:collection_id])
    if collection.update_attributes(:title=>params[:title])
      return render :json=>current_user.created_collections_db
    end
    render :text=>"api0 收集册重命名失败",:status=>400
  end

  # -------- 以下是一些公共私有方法 --------
  private
    def api0_feed_json_hash(feed)
      user = feed.creator

      return {
        :created_at => feed.created_at,
        :updated_at => feed.updated_at,
        :id         => feed.id,
        :title      => feed.android_title_text,
        :detail     => MindpinTextFormat.new(feed.detail).to_text,
        :from       => feed.from,
        :photos_thumbnail => feed.photos.map{|p|p.image.url(:s100)},
        :photos_middle    => feed.photos.map{|p|p.image.url(:w210)},
        :photos_large     => feed.photos.map{|p|p.image.url(:w660)},
        :user       => user.api0_json_hash(current_user)
      }
    end
end