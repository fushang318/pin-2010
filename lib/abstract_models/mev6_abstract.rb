class Mev6Abstract < ActiveRecord::Base
  self.abstract_class = true
  build_database_connection(CoreService::MEV6)
end
