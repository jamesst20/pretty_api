module PrettyApi
  module Helpers
    extend ActiveSupport::Concern

    included do
      def pretty_nested_attributes(record, params, attrs = nil)
        attrs ||= PrettyApi::ActiveRecord::Associations.nested_attributes_associations(record.class)

        PrettyApi::Parameters::NestedAttributes.parse_nested_attributes(record, params.dup, attrs)
      end

      def pretty_nested_errors(record, attrs = nil)
        attrs ||= PrettyApi::ActiveRecord::Associations.nested_attributes_associations(record.class)

        PrettyApi::Errors::NestedErrors.parsed_nested_errors(record, attrs)
      end
    end
  end
end
