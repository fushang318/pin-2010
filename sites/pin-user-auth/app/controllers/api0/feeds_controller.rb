class Api0::FeedsController < ApplicationController
  before_filter :api0_need_login
  def api0_need_login
    return render :text=>'api0需要在登录状态下访问',:status=>401 if !logged_in?
  end

  #    :collection_id  必须  收集册的id
  #    :since_id 非必须，若指定此参数，则只获取ID比since_id大的feed信息
  #    :max_id 非必须，弱指定此参数，则只获取ID小于或等于max_id的feed信息
  #    :count 非必须 默认20，最大100，单页返回的结果条数
  #    :page 非必须，返回结果的页码，默认1
  def collection_feeds
    collection = Collection.find(params[:collection_id])
    feeds = collection.feeds_limit({
        :since_id=>params[:since_id],
        :max_id=>params[:max_id],
        :count=>params[:count],
        :page=>params[:page]
      })

    render :json=>feeds.map{|feed|
      user = feed.creator

      {
        :created_at => feed.created_at,
        :id         => feed.id,
        :title      => feed.android_title_text,
        :detail     => MindpinTextFormat.new(feed.detail).to_text,
        :from       => feed.from,
        :photos_thumbnail => feed.photos.map{|p|p.image.url(:s100)},
        :photos_middle    => feed.photos.map{|p|p.image.url(:w210)},
        :photos_large     => feed.photos.map{|p|p.image.url(:w660)},
        :user       => {
          :name       => user.name,
          :sign       => user.sign,
          :id         => user.id,
          :following  => current_user.following?(user),
          :avatar_url => user.logo.url,
        }
      }
    }

  end
end
