module PrettyApi
  module ActiveRecord
    class Associations
      def self.nested_attributes_tree(model, result = {})
        model.nested_attributes_options.each_key do |association_name|
          result[model] ||= {}

          association = attribute_association(model, association_name)
          association_class = association.klass

          result[model][association_name] = {
            model: association_class,
            type: association.macro,
            allow_destroy: attribute_destroy_allowed?(model, association_name)
          }

          next if result.key?(association_class)

          result[association_class] = {}
          nested_attributes_tree(association_class, result)
        end
        result
      end

      def self.attribute_destroy_allowed?(model, attribute)
        model.nested_attributes_options[attribute.to_sym][:allow_destroy] == true
      end

      def self.attribute_association(model, attribute)
        model.reflect_on_association(attribute).chain.last
      end
    end
  end
end
