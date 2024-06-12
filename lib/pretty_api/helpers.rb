module PrettyApi
  module Helpers
    extend ActiveSupport::Concern

    included do
      def pretty_nested_attributes(record, params, attrs = nil)
        params = params.to_h.with_indifferent_access

        attrs ||= PrettyApi::ActiveRecord::Associations.nested_attributes_tree(record.class)

        PrettyApi::Parameters::NestedAttributes.new(nested_tree: attrs).parse(record, params)
      end

      def pretty_nested_errors(record, attrs = nil)
        attrs ||= PrettyApi::ActiveRecord::Associations.nested_attributes_tree(record.class)

        PrettyApi::Errors::NestedErrors.new(nested_tree: attrs).parse(record)
      end

      alias_method :pretty_attrs, :pretty_nested_attributes
      alias_method :pretty_errors, :pretty_nested_errors
    end
  end
end
