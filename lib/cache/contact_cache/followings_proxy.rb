class FollowingsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "followings_contacts_vector_#{@user.id}"
  end

  def xxxs_ids_db
    Contact.find(
      :all,
      :conditions=>"user_id = #{@user.id}",
      :order=>"id desc").map{|c| c.id} # 读数据库
  end
end
