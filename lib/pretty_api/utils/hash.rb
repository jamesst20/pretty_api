module PrettyApi
  module Utils
    class Hash
      def self.deep_compact_blank(hash)
        hash.each_with_object({}) do |(k, v), new_hash|
          v = deep_compact_blank(v) if v.is_a? ::Hash
          v = v.compact_blank if v.is_a? ::Array
          new_hash[k] = v if v.present?
        end
      end
    end
  end
end
