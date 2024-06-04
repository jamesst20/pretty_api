module PrettyApi
  module Parameters
    class NestedAttributes
      def initialize(nested_tree:)
        @nested_tree = nested_tree
      end

      def parse(record, params)
        parse_nested_attributes(record, params, nested_tree[record.class])
      end

      private

      attr_reader :nested_tree

      def parse_nested_attributes(record, params, attrs)
        return {} if params.blank?

        attrs.each do |assoc_key, assoc_info|
          next unless params.key?(assoc_key)

          parse_deep_nested_attributes(record, params, assoc_key, assoc_info)

          include_associations_to_destroy(record, params, assoc_key, assoc_info)
          params["#{assoc_key}_attributes"] = params.delete(assoc_key)
        end

        params
      end

      def parse_deep_nested_attributes(record, params, assoc_key, assoc_info)
        if assoc_info[:type] == :has_many
          parse_has_many_association(record, params, assoc_key, assoc_info)
        else
          parse_has_one_association(record, params, assoc_key, assoc_info)
        end
      end

      def parse_has_many_association(record, params, assoc_key, assoc_info)
        # www-form-urlencoded / multipart-form-data
        params[assoc_key] = params[assoc_key].values if params[assoc_key].is_a?(Hash)

        (params[assoc_key] || []).each do |p|
          assoc_primary_key = record.try(:class).try(:primary_key)
          assoc = record.try(assoc_key).try(:detect) { |r| r.try(assoc_primary_key) == p[assoc_primary_key] }
          parse_nested_attributes(assoc, p, nested_tree[assoc_info[:model]])
        end
      end

      def parse_has_one_association(record, params, assoc_key, assoc_info)
        parse_nested_attributes(record.try(assoc_key), params[assoc_key], nested_tree[assoc_info[:model]])
      end

      def include_associations_to_destroy(record, params, assoc_key, assoc_info)
        return unless PrettyApi.destroy_missing_associations && record.present?

        return unless assoc_info[:allow_destroy]

        primary_key = assoc_info[:model].primary_key
        assoc_type = assoc_info[:type]

        include_has_many_to_destroy(record, params, assoc_key, primary_key) if assoc_type == :has_many
        include_has_one_to_destroy(record, params, assoc_key, primary_key) if assoc_type.in?(%i[has_one belongs_to])
      end

      def include_has_many_to_destroy(record, params, attr, primary_key)
        ids_to_destroy = PrettyApi::ActiveRecord::Orm
                           .where_not(record.send(attr), primary_key, params[attr].pluck(primary_key))
                           .pluck(primary_key)

        params[attr].push(*ids_to_destroy.map { |id| { primary_key => id, _destroy: true } })
      end

      def include_has_one_to_destroy(record, params, attr, primary_key)
        association_id = record.send(attr).try(primary_key)

        return if association_id.blank?
        return if params[attr].try(:[], primary_key).present?

        params[attr] ||= {}
        params[attr].merge!({ primary_key => association_id, _destroy: true })
      end
    end
  end
end
