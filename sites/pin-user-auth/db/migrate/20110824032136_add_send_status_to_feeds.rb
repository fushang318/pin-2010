class AddSendStatusToFeeds < ActiveRecord::Migration
  def self.up
    add_column(:feeds, :send_status, :string)
  end

  def self.down
  end
end
