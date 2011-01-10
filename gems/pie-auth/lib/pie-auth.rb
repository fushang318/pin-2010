module PieAuth
  class << self
    def auth_include_modules
      if defined? ActiveRecord::Base
        require 'pie-auth/set_readonly'
        ActiveRecord::Base.send :include, SetReadonly
        require 'pie-auth/build_database_connection'
        ActiveRecord::Base.send :include, BuildDatabaseConnection
        require "paperclip"
        ActiveRecord::Base.send :include, Paperclip
      end
      if defined? ActionView::Base
        require "pie-auth/project_link_module"
        ActionView::Base.send :include, ProjectLinkModule
      end
      if defined? ActionController::Base
        require 'pie-auth/authenticated_system'
        ActionController::Base.send :include,AuthenticatedSystem
      end
    end
  end
end

# 一些 对 rails 的 扩展
if defined? Rails
  PieAuth.auth_include_modules
end

require 'pie-auth/core_service'
require 'pie-auth/email_actor'

# user 信息 需要的类
if defined? ActiveRecord::Base

  begin
    require 'cache_money'
    require 'memcache'
    config = YAML.load(IO.read(File.join(RAILS_ROOT, "config", "memcached.yml")))[RAILS_ENV]
    $memcache = MemCache.new(config)
    $memcache.servers = config['servers']

    $local = Cash::Local.new($memcache)
    $lock = Cash::Lock.new($memcache)
    $cache = Cash::Transactional.new($local, $lock)

    p '加载工程 cache money 配置'

    class ActiveRecord::Base
      is_cached :repository => $cache
    end
  rescue Exception => ex
    p ex.message
  end


  require 'pie-auth/member_base'
  require 'pie-auth/organization_base'
  require 'pie-auth/user_base'
  require 'pie-auth/preference'
end
# 一些 helper 方法
include ProjectLinkModule

begin
  CoreService.reset_config
rescue Exception => ex
  code
end