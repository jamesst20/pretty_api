module PrettyApi
  module ActiveRecord
    class Orm
      def self.where_not(record, attribute, values)
        record.where.not(attribute => values)
      end
    end
  end
end
