class ShortUrl < UserAuthAbstract
  validates_presence_of :url
  validates_uniqueness_of :url
  validates_uniqueness_of :code

  SHORT_SITE = case Rails.env
  when "development" then "d.mup.cc"
  else
    "mup.cc"
  end

  URL_REGEX = %r{
    (
      (?:https?://)            # protocol spec, or
    )
    (
      [-0-9A-Za-z_]+           # subdomain or domain
      (?:\.[-0-9A-Za-z_]+)*    # remaining subdomains or domain
      (?::\d+)?                # port
      (?:/(?:(?:[~0-9A-Za-z_\+%-]|(?:[,.;:][^\s$]))+)?)* # path
      (?:\?[0-9A-Za-z_\+%&=.;-]+)?     # query string
      (?:\#[0-9A-Za-z_\-]*)?   # trailing anchor
    )
  }x

  before_create :check_code
  def check_code
    self.code = self.create_a_not_existed_code
  end
  # 查找这个code是否在数据库中存在，如果存在了，
  # 那么生成一个确保不存在的
  def create_a_not_existed_code
    code = ShortUrl.short(self.url)
    # 数据库中如果存在，则重新创建，确保唯一性
    while true
      return code if !ShortUrl.find_by_code(code)
      code = ShortUrl.short(self.url,code.length + 1)
    end
  end

  # 得到url的code
  def self.short(str,length=4)
    base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    size = base.size
    md5str = Digest::MD5.digest(str)

    re = ''
    len = [md5str.length,length].min - 1

    0.upto len do |i|
      j = md5str[i] % size
      re << base[j]
    end

    re
  end

  def self.get_url_by_code(code)
    short_url = ShortUrl.find_by_code(code)
    return if short_url.blank?
    short_url.url
  end

  # 根据url返回它对应的short_url
  def self.get_short_url(url)
    uri = URI.parse(url)
    # 防止重复转换
    return url if uri.host == SHORT_SITE
    short_url = ShortUrl.find_by_url(url)
    if short_url.blank?
      short_url = ShortUrl.create(:url=>url)
    end
    return short_url.short_url_str
  end

  def short_url_str
    return "http://#{SHORT_SITE}/#{self.code}"
  end

  module FeedMethods
    def self.included(base)
      base.before_validation :replace_url_to_short_url, :on=>:create
    end

    def replace_url_to_short_url
      self.detail.gsub!(ShortUrl::URL_REGEX) do
        ShortUrl.get_short_url($&)
      end
    end
  end

end
