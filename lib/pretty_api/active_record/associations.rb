module PrettyApi
  module ActiveRecord
    class Associations
      def self.nested_attributes_tree(model, structure = :array)
        if structure == :array
          nested_attributes_tree_array(model)
        elsif structure == :hash
          nested_attributes_tree_hash(model)
        end
      end

      def self.nested_attributes_tree_hash(model, depth = {})
        nested_attributes_descriptions(model).index_by { |a| a[:id] }.each_with_object({}) do |(key, assoc), result|
          depth[key] ||= 0

          next unless depth[key] < PrettyApi.max_nested_attributes_depth

          depth[key] += 1
          result[assoc[:name]] = nested_attributes_tree_hash(assoc[:model], depth)
          depth[key] -= 1
        end
      end

      def self.nested_attributes_tree_array(model, depth = {})
        nested_attributes_descriptions(model).index_by { |a| a[:id] }.map do |(key, association)|
          depth[key] ||= 0

          next nil if depth[key] >= PrettyApi.max_nested_attributes_depth

          depth[key] += 1
          result = { association[:name] => nested_attributes_tree_array(association[:model], depth) }
          depth[key] -= 1

          result.compact_blank.blank? ? association[:name] : result
        end.compact_blank
      end

      def self.nested_attributes_descriptions(model)
        model.nested_attributes_options.keys.map do |association_name|
          association_model = attribute_association_class(model, association_name)
          {
            id: "#{model}_#{association_name}",
            name: association_name,
            model: association_model,
            associations: association_model.nested_attributes_options.keys.map do |n|
              attribute_association_class(association_model, n)
            end
          }
        end
      end

      def self.attribute_destroy_allowed?(model, attribute)
        model.nested_attributes_options[attribute.to_sym][:allow_destroy] == true
      end

      def self.attribute_association(model, attribute)
        model.reflect_on_association(attribute).chain.last
      end

      def self.attribute_association_class(model, attribute)
        model.reflect_on_association(attribute).class_name.constantize
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
