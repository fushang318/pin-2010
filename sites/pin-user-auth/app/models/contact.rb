class Contact < ContactBase
  set_readonly(false)
  belongs_to :user
  
  validates_presence_of :user_id
  validates_presence_of :email
  validates_format_of :email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  index :user_id

  # 添加联系人的时候，在这个人的默认频道中添加这个redis缓存
  after_save :add_user_no_channel_user_id
  def add_user_no_channel_user_id
    NoChannelUsersProxy.new(user).add_contact(self)
    return true
  end

  # 删除contact的时候 已经级联删除 channle_contacts
  # 删除channel_contact 有回调 删除channel中user_ids对应的reids缓存
  after_destroy :remove_user_no_channel_user_id
  def remove_user_no_channel_user_id
    NoChannelUsersProxy.new(user).remove_contact(self)
    return true
  end

  def validate
    cons = Contact.find_all_by_user_id_and_email(user.id,email)
    add_user = EmailActor.get_user_by_email(email)
    errors.add("email","系统内没有这个用户") if add_user.blank?
    errors.add("email","已经添加过该联系人") if add_user && !cons.blank?
    errors.add("email","不能添加自己为联系人") if add_user && add_user.id == user.id
  end

  module UserMethods
    def self.included(base)
      base.has_many :contacts
    end
  end

  include ContactProxy::ContactMethods
  include ChannelContact::ContactMethods
  include NewsFeedProxy::ContactMethods
end
