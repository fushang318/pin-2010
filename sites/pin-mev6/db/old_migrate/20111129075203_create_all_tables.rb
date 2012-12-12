class CreateAllTables < ActiveRecord::Migration
  def change
    create_table "cooperation_channels", :force => true do |t|
      t.integer  "mindmap_id"
      t.integer  "channel_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "cooperation_users", :force => true do |t|
      t.integer  "mindmap_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "cooperations", :force => true do |t|
      t.integer  "mindmap_id"
      t.string   "email"
      t.string   "kind"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "history_records", :force => true do |t|
      t.string   "kind"
      t.string   "params_json"
      t.integer  "mindmap_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "email"
      t.text     "struct"
    end
    add_index "history_records", ["mindmap_id"], :name => "mindmap_id_index"

    create_table "image_attachments", :force => true do |t|
      t.integer  "user_id"
      t.string   "image_file_name"
      t.string   "image_content_type"
      t.integer  "image_file_size"
      t.datetime "image_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "image_meta"
    end

    create_table "image_caches", :force => true do |t|
      t.integer  "mindmap_id"
      t.string   "size_param"
      t.string   "img_file_name"
      t.string   "img_content_type"
      t.integer  "img_file_size"
      t.datetime "img_updated_at"
      t.datetime "mindmap_last_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "mindmap_comments", :force => true do |t|
      t.integer  "mindmap_id"
      t.integer  "creator_id"
      t.text     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "mindmap_favs", :force => true do |t|
      t.integer  "user_id"
      t.integer  "mindmap_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "mindmap_files", :force => true do |t|
      t.integer  "mindmap_id"
      t.string   "file_file_name"
      t.string   "file_content_type"
      t.integer  "file_file_size"
      t.datetime "file_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "mindmaps", :force => true do |t|
      t.integer  "user_id",                                                        :null => false
      t.string   "title",                                                          :null => false
      t.string   "description"
      t.text     "struct",                    :limit => 2147483647
      t.float    "score"
      t.boolean  "private"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "weight"
      t.text     "content"
      t.integer  "clone_from"
      t.string   "note_nid"
      t.text     "old_struct"
      t.integer  "modified_times",                                  :default => 0
      t.integer  "current_history_record_id"
      t.string   "send_status"
    end

    add_index "mindmaps", ["created_at"], :name => "index_pinmaps_on_created_at"
    add_index "mindmaps", ["send_status"], :name => "index_mindmaps_on_send_status"
    add_index "mindmaps", ["updated_at"], :name => "index_pinmaps_on_updated_at"
    add_index "mindmaps", ["user_id"], :name => "index_pinmaps_on_user_id"

    create_table "nodes", :force => true do |t|
      t.integer  "mindmap_id",                       :null => false
      t.string   "local_id"
      t.text     "note",       :limit => 2147483647
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "nodes", ["mindmap_id", "local_id"], :name => "index_nodes_on_pinmap_id_and_local_id"
    add_index "nodes", ["mindmap_id"], :name => "index_nodes_on_pinmap_id"

    create_table "rates", :force => true do |t|
      t.integer  "user_id"
      t.integer  "rateable_id"
      t.string   "rateable_type", :limit => 30
      t.integer  "rate"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "rates", ["rateable_id"], :name => "index_rates_on_rateable_id"
    add_index "rates", ["user_id"], :name => "index_rates_on_user_id"

    create_table "snapshots", :force => true do |t|
      t.integer  "mindmap_id"
      t.string   "title"
      t.text     "struct"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "taggings", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.datetime "created_at"
    end
    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

    create_table "tags", :force => true do |t|
      t.string "name"
    end

    create_table "visit_counters", :force => true do |t|
      t.integer  "resource_id",                  :null => false
      t.string   "resource_type",                :null => false
      t.integer  "visit_count",   :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "visit_counters", ["resource_id", "resource_type"], :name => "index_visit_counters_on_resource_id_and_resource_type"
  end
end