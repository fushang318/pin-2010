require 'openssl'
require 'base64'
require 'digest/md5'

class Oss
  class NoSuchBucketError < StandardError;end
  class ResponseError < StandardError;end

  def initialize(access_key_id,secret_access_key)
    @access_key_id = access_key_id
    @secret_access_key = secret_access_key
  end

  def create_bucket(bucket)
    path = "/#{bucket}"
    method = "PUT"
    head_hash = get_head_hash(method,path)
    
    Net::HTTP.start('storage.aliyun.com') do |http|
      r = http.send_request(method,path,nil,head_hash)
      process_bucket_response(r)
    end
  end

  def set_bucket_acl(bucket,acl)
    path = "/#{bucket}"
    method = "PUT"
    header = {"x-oss-acl"=>acl}

    head_hash = get_head_hash(method,path,:header=>header)
    
    Net::HTTP.start('storage.aliyun.com') do |http|
      r = http.send_request(method,path,nil,head_hash)
      process_bucket_response(r)
    end
  end

  def upload_file(bucket,file,save_path,content_type)
    path = File.join("/",bucket,save_path)
    method = "PUT"
    body = IO.read(file.path)
    md5 = Digest::MD5.hexdigest(body)
    content_length = body.length

    head_hash = get_head_hash(method,path,:content_length=>content_length,:md5=>md5,:content_type=>content_type)
    Net::HTTP.start('storage.aliyun.com') do |http|
      r = http.send_request(method,path,body,head_hash)
      process_object_response(r)
    end
  end

  def delete_file(bucket,save_path)
    path = File.join("/",bucket,save_path)
    method = "DELETE"
    head_hash = get_head_hash(method,path)
    
    Net::HTTP.start('storage.aliyun.com') do |http|
      r = http.send_request(method,path,nil,head_hash)
      process_object_response(r)
    end
  end

  private
  def get_head_hash(method,path,option={})
    date = Time.now.gmtime.strftime('%a, %d %b %Y %H:%M:%S %Z')
    oss_sign = ali_oss_sign(method, date, path,option)
    hash = {'Authorization'=>"OSS #{@access_key_id}:#{oss_sign}",'Date'=>date}
    unless option[:header].blank?
      hash.merge!(option[:header])
    end
    unless option[:md5].blank?
      hash.merge!("Content-Md5"=>option[:md5])
    end
    unless option[:content_type].blank?
      hash.merge!("Content-Type"=>option[:content_type])
    end

    hash
  end

  def ali_oss_sign(verb, date, res,options={})
    digest  = OpenSSL::Digest::Digest.new('sha1')

    md5 = options[:md5] || ''
    ty = options[:content_type] || ''

    header = ''
    unless options[:header].blank?
      header = options[:header].map{|keya,value|"#{keya}:#{value}"}*"\n" + "\n"
    end

    str = "#{verb}\n#{md5}\n#{ty}\n#{date}\n#{header}#{res}"
    
    bytemac = OpenSSL::HMAC.digest(digest, @secret_access_key, str)
    res = Base64.encode64(bytemac).strip
  end

  def process_object_response(response)
    case response.code
    when "404"
      raise Oss::NoSuchBucketError
    when "200"
      return true
    else
      raise Oss::ResponseError
    end
  end

  def process_bucket_response(response)
    case response.code
    when "200"
      return true
    else
      raise Oss::ResponseError
    end
  end

end
