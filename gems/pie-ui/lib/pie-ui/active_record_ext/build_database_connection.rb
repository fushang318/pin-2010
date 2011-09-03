module PieUi
  module BuildDatabaseConnection

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # options中可以添加 table_name 这个参数  来满足下面这种情况：
      # class name 有时候会和表名取不一样的。应该允许用户指定连接哪一个表
      def build_database_connection(name,options={})
        database = CoreService.find_database_by_project_name(name)
        if RAILS_ENV != "test"
          establish_connection(database)
        end

        unless options[:table_name].blank?
          set_table_name(options[:table_name])
        end

      end
    end

  end
end