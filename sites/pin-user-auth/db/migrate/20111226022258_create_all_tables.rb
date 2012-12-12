class CreateAllTables < ActiveRecord::Migration
  def change
    create_table "activation_codes", :force => true do |t|
      t.string   "code"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "activities", :force => true do |t|
      t.string   "operator"
      t.string   "event"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "location"
      t.string   "detail"
    end

    create_table "apply_records", :force => true do |t|
      t.string   "email"
      t.string   "name"
      t.text     "description"
      t.integer  "code_id"
      t.boolean  "mail_has_send"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "apps", :force => true do |t|
      t.string   "name"
      t.string   "title"
      t.string   "callback_url"
      t.integer  "port",              :default => 80
      t.string   "secret_key"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.string   "developer"
      t.text     "subject"
    end
    add_index "apps", ["name"], :name => "index_apps_on_name"

    create_table "atmes", :force => true do |t|
      t.integer  "user_id"
      t.integer  "atable_id"
      t.string   "atable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "creator_id"
    end

    create_table "channel_contacts", :force => true do |t|
      t.integer  "channel_id"
      t.integer  "contact_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "channel_users", :force => true do |t|
      t.integer  "channel_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "channels", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal  "position",   :precision => 15, :scale => 5
      t.integer  "creator_id"
    end

    create_table "collection_scopes", :force => true do |t|
      t.integer  "collection_id"
      t.string   "param"
      t.integer  "scope_id"
      t.string   "scope_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "collections", :force => true do |t|
      t.string   "title"
      t.string   "description"
      t.integer  "creator_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "send_status"
      t.boolean  "active",      :default => true
    end

    create_table "connect_users", :force => true do |t|
      t.integer  "user_id"
      t.string   "connect_type"
      t.string   "connect_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "oauth_token"
      t.string   "oauth_token_secret"
      t.text     "account_detail"
      t.boolean  "oauth_invalid"
      t.boolean  "syn_from_connect"
      t.string   "last_syn_message_id"
    end

    create_table "contacts", :force => true do |t|
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "follow_user_id"
    end

    create_table "favs", :force => true do |t|
      t.integer  "user_id"
      t.integer  "feed_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "feed_collections", :force => true do |t|
      t.integer  "feed_id"
      t.integer  "collection_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "feed_invites", :force => true do |t|
      t.integer  "feed_id"
      t.integer  "creator_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "feed_revisions", :force => true do |t|
      t.integer  "feed_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "title"
      t.text     "detail"
      t.string   "tag_ids_json"
      t.string   "message",      :default => "", :null => false
    end

    create_table "feed_tags", :force => true do |t|
      t.integer  "feed_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "tag_id"
    end

    create_table "feed_viewings", :force => true do |t|
      t.integer  "feed_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "feed_votes", :force => true do |t|
      t.integer  "feed_id"
      t.integer  "user_id"
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "feeds", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "repost_feed_id"
      t.integer  "creator_id"
      t.boolean  "hidden",              :default => false, :null => false
      t.boolean  "locked",              :default => false, :null => false
      t.integer  "vote_score",          :default => 0
      t.integer  "feed_viewings_count", :default => 0
      t.string   "from"
    end

    create_table "login_wallpapers", :force => true do |t|
      t.string   "image_file_name"
      t.string   "image_content_type"
      t.integer  "image_file_size"
      t.datetime "image_updated_at"
      t.text     "image_meta"
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "in_cycle_list",      :default => false
      t.integer  "user_id"
    end

    create_table "media_thumbnails", :force => true do |t|
      t.string   "url"
      t.string   "thumb_src"
      t.string   "host"
      t.string   "time"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "messages", :force => true do |t|
      t.integer  "reader_id"
      t.string   "sender_email"
      t.string   "receiver_email"
      t.boolean  "has_read"
      t.text     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "online_records", :force => true do |t|
      t.integer  "user_id"
      t.string   "key"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "online_records", ["key"], :name => "index_online_records_on_key"
    add_index "online_records", ["user_id"], :name => "index_online_records_on_user_id"

    create_table "photo_comments", :force => true do |t|
      t.integer  "photo_id"
      t.text     "content"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "photos", :force => true do |t|
      t.integer  "user_id"
      t.string   "image_file_name"
      t.string   "image_content_type"
      t.integer  "image_file_size"
      t.datetime "image_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "description"
      t.string   "image_fingerprint"
      t.text     "image_meta"
    end

    create_table "post_comments", :force => true do |t|
      t.integer  "post_id"
      t.integer  "user_id"
      t.text     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "reply_comment_id"
      t.integer  "reply_comment_user_id"
    end
    add_index "post_comments", ["reply_comment_id"], :name => "index_post_comments_on_reply_comment_id"
    add_index "post_comments", ["reply_comment_user_id"], :name => "index_post_comments_on_reply_comment_user_id"

    create_table "post_drafts", :force => true do |t|
      t.integer  "user_id"
      t.integer  "feed_id"
      t.text     "detail"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
      t.string   "photo_ids"
      t.string   "collection_ids"
      t.string   "text_format",    :default => "markdown", :null => false
      t.string   "draft_token"
    end

    create_table "post_photos", :force => true do |t|
      t.integer  "photo_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "post_id"
    end

    create_table "post_revisions", :force => true do |t|
      t.integer  "post_id"
      t.text     "content"
      t.string   "message"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "post_spam_marks", :force => true do |t|
      t.integer  "post_id"
      t.integer  "user_id"
      t.integer  "count"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "post_votes", :force => true do |t|
      t.integer  "user_id"
      t.integer  "post_id"
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "post_with_users", :force => true do |t|
      t.integer  "post_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "posts", :force => true do |t|
      t.integer  "todo_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal  "position",    :precision => 15, :scale => 5
      t.string   "status"
      t.text     "detail",                                                             :null => false
      t.integer  "vote_score",                                 :default => 0
      t.integer  "feed_id"
      t.string   "kind",                                       :default => "normal",   :null => false
      t.string   "text_format",                                :default => "markdown", :null => false
      t.text     "title",                                                              :null => false
      t.string   "location"
    end

    create_table "preferences", :force => true do |t|
      t.integer  "todo_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal  "position",    :precision => 15, :scale => 5
      t.string   "status"
      t.text     "detail",                                                             :null => false
      t.integer  "vote_score",                                 :default => 0
      t.integer  "feed_id"
      t.string   "kind",                                       :default => "normal",   :null => false
      t.string   "text_format",                                :default => "markdown", :null => false
      t.text     "title",                                                              :null => false
      t.string   "location"
    end

    create_table "preferences", :force => true do |t|
      t.integer  "user_id",                                              :null => false
      t.string   "messages_set",            :default => "only_contacts"
      t.boolean  "hide_startup"
      t.integer  "last_feature_update_id",  :default => 0,               :null => false
      t.string   "usage"
      t.string   "head_cover_file_name"
      t.string   "head_cover_content_type"
      t.integer  "head_cover_file_size"
      t.datetime "head_cover_updated_at"
    end
    add_index "preferences", ["user_id"], :name => "index_preferences_on_user_id"

    create_table "reputation_logs", :force => true do |t|
      t.integer  "user_id"
      t.string   "kind"
      t.text     "info_json"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "send_scopes", :force => true do |t|
      t.string   "param"
      t.integer  "feed_id"
      t.integer  "scope_id"
      t.string   "scope_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "short_urls", :force => true do |t|
      t.text     "url"
      t.string   "code"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "spam_marks", :force => true do |t|
      t.integer  "feed_id"
      t.integer  "user_id"
      t.integer  "count"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "tag_another_names", :force => true do |t|
      t.string   "name"
      t.integer  "tag_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "tag_detail_revisions", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "user_id"
      t.text     "detail"
      t.string   "message"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "tag_favs", :force => true do |t|
      t.integer  "user_id"
      t.integer  "tag_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "tag_shares", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "creator_id"
      t.string   "url"
      t.string   "title"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "tags", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.text     "detail"
      t.string   "namespace"
    end
    add_index "tags", ["name"], :name => "index_tags_on_name"

    create_table "user_logs", :force => true do |t|
      t.integer  "user_id"
      t.string   "kind"
      t.text     "info_json"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "user_view_posts", :force => true do |t|
      t.integer  "user_id"
      t.integer  "post_id"
      t.string   "attitude"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "users", :force => true do |t|
      t.string   "name",                      :default => "", :null => false
      t.string   "hashed_password",           :default => "", :null => false
      t.string   "salt",                      :default => "", :null => false
      t.string   "email",                     :default => "", :null => false
      t.string   "sign"
      t.string   "activation_code"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "activated_at"
      t.string   "reset_password_code"
      t.datetime "reset_password_code_until"
      t.datetime "last_login_time"
      t.boolean  "send_invite_email"
      t.integer  "reputation",                :default => 0,  :null => false
    end
    add_index "users", ["email"], :name => "email_index"

    create_table "weibo_carts", :force => true do |t|
      t.integer  "user_id"
      t.string   "mid"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "weibo_carts", ["mid"], :name => "index_weibo_carts_on_mid"

    create_table "weibo_statuses", :force => true do |t|
      t.string   "mid"
      t.string   "uname"
      t.integer  "uid"
      t.text     "json"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "weibo_statuses", ["mid"], :name => "index_weibo_statuses_on_mid"

  end
end