module PrettyApi
  module Parameters
    class NestedAttributes
      def self.parse_nested_attributes(record, params, attrs)
        return {} if params.blank?

        if [Hash, Array].include?(attrs.class)
          parse_deep_nested_attributes(record, params, attrs)
        elsif params.is_a? Array
          params.each_with_index { |p, i| parse_nested_attributes record.try(:[], i), p, attrs }
        elsif params.key?(attrs)
          include_associations_to_destroy(record, params, attrs)
          params["#{attrs}_attributes"] = params.delete attrs
        end

        params
      end

      def self.parse_deep_nested_attributes(record, params, attrs)
        case attrs
        when Hash
          attrs.each do |key, value|
            parse_nested_attributes record.try(key), params[key], value
            parse_nested_attributes record, params, key
          end
        when Array
          attrs.each { |value| parse_nested_attributes record, params, value }
        end
      end

      def self.include_associations_to_destroy(record, params, attr)
        return unless PrettyApi.destroy_missing_associations && record.present?

        association = PrettyApi::ActiveRecord::Associations.attribute_association(record.class, attr)

        return unless PrettyApi::ActiveRecord::Associations.attribute_destroy_allowed?(record.class, attr)

        primary_key = PrettyApi::ActiveRecord::Associations.association_primary_key(association)

        assoc_type = PrettyApi::ActiveRecord::Associations.association_type(association)

        include_has_many_to_destroy(record, params, attr, primary_key) if assoc_type == :has_many
        include_has_one_to_destroy(record, params, attr, primary_key) if assoc_type.in?(%i[has_one belongs_to])
      end

      def self.include_has_many_to_destroy(record, params, attr, primary_key)
        ids_to_destroy = PrettyApi::ActiveRecord::Orm
                           .where_not(record.send(attr), primary_key, params[attr].pluck(primary_key))
                           .pluck(primary_key)

        params[attr].push(*ids_to_destroy.map { |id| { primary_key => id, _destroy: true } })
      end

      def self.include_has_one_to_destroy(record, params, attr, primary_key)
        association_id = record.send(attr).try(primary_key)

        return if association_id.blank?
        return if params[attr].try(:[], primary_key).present?

        params[attr] ||= {}
        params[attr].merge!({ primary_key => association_id, _destroy: true })
      end
    end
  end
end
