module PrettyApi
  module ActiveRecord
    class Associations
      def self.nested_attributes_associations(model, prev = nil)
        model.nested_attributes_options.keys.map do |nested_attr_assoc|
          nested_assoc_model = model.reflect_on_association(nested_attr_assoc).class_name.constantize

          next nested_attr_assoc unless nested_assoc_model.nested_attributes_options.keys.any?
          next nil if prev == nested_assoc_model

          { nested_attr_assoc => nested_attributes_associations(nested_assoc_model, model) }
        end.compact_blank
      end

      def self.attribute_destroy_allowed?(model, attribute)
        model.nested_attributes_options[attribute.to_sym][:allow_destroy] == true
      end

      def self.attribute_association(model, attribute)
        model.reflect_on_association(attribute)&.chain&.last
      end

      def self.association_type(association)
        association.macro
      end

      def self.association_primary_key(association)
        association.class_name.constantize.primary_key
      end
    end
  end
end
