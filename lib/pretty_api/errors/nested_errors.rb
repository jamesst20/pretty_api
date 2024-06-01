module PrettyApi
  module Errors
    class NestedErrors
      def initialize(nested_tree:)
        @nested_tree = nested_tree
      end

      def parse(record)
        errors = record_only_errors(record)

        return errors if nested_tree.blank?

        parse_deep_nested_errors(record, nested_tree[record.class], errors)

        PrettyApi::Utils::Hash.deep_compact_blank(errors)
      end

      private

      attr_reader :nested_tree

      def parse_deep_nested_errors(record, attrs, result, parent_record = nil)
        attrs.each do |assoc_key, assoc_info|
          association = record.send(assoc_key)

          next if association.blank?
          next if association == parent_record

          if association.respond_to? :to_a
            parse_has_many_errors(record, association, assoc_key, assoc_info, result)
          else
            parse_has_one_errors(record, association, assoc_key, assoc_info, result)
          end
        end
      end

      def parse_has_many_errors(record, associations, assoc_key, assoc_info, result)
        result[assoc_key] = {}
        associations.each_with_index do |association, i|
          result[assoc_key][i] = record_only_errors(association)
          parse_deep_nested_errors association, nested_tree[assoc_info[:model]], result[assoc_key][i], record
        end
      end

      def parse_has_one_errors(record, association, assoc_key, assoc_info, result)
        result[assoc_key] = record_only_errors(association)
        parse_deep_nested_errors association, nested_tree[assoc_info[:model]], result[assoc_key], record
      end

      def record_only_errors(record)
        record.errors.as_json.reject { |k, _v| k.to_s.include?(".") }
      end
    end
  end
end
