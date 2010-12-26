class Member < MemberBase
  set_readonly(false)
  belongs_to :organization
  belongs_to :user,:foreign_key=>"email",:primary_key=>"email"

  validates_presence_of :organization
  validates_presence_of :email
  validates_format_of :email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  def validate
    if organization.has_email?(email)
      errors.add("email","该成员已经加入团队")
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :members,:foreign_key=>"email",:primary_key=>"email"
    end
  end

end
