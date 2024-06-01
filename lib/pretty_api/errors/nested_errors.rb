module PrettyApi
  module Errors
    class NestedErrors
      def self.parsed_nested_errors(record, attrs)
        errors = record_only_errors(record)

        return errors if attrs.blank?

        parse_deep_nested_errors(record, attrs, errors)

        PrettyApi::Utils::Hash.deep_compact_blank(errors)
      end

      def self.parse_deep_nested_errors(record, attrs, result, parent_record = nil)
        case attrs
        when Hash
          attrs.each do |key, value|
            parse_association_errors(record, key, value, result, parent_record)
          end
        when Array
          attrs.each { |value| parse_deep_nested_errors record, value, result, parent_record }
        else
          parse_association_errors(record, attrs, nil, result, parent_record)
        end
      end

      def self.parse_association_errors(record, attr, nested_attrs, result, parent_record)
        association = record.send(attr)

        return if association.blank?
        return if association == parent_record

        if association.respond_to? :to_a
          parse_has_many_errors(record, association, attr, nested_attrs, result)
        else
          parse_has_one_errors(record, association, attr, nested_attrs, result)
        end
      end

      def self.parse_has_many_errors(record, associations, attr, nested_attrs, result)
        result[attr] = {}
        associations.each_with_index do |association, i|
          result[attr][i] = record_only_errors(association)
          parse_deep_nested_errors association, nested_attrs, result[attr][i], record if nested_attrs.present?
        end
      end

      def self.parse_has_one_errors(record, association, attr, nested_attrs, result)
        result[attr] = record_only_errors(association)
        parse_deep_nested_errors association, nested_attrs, result[attr], record if nested_attrs.present?
      end

      def self.record_only_errors(record)
        record.errors.as_json.reject { |k, _v| k.to_s.include?(".") }
      end
    end
  end
end
