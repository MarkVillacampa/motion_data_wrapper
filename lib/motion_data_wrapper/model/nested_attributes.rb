module MotionDataWrapper
  class Model < NSManagedObject
    module NestedAttributes

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def accepted_nested_attributes
          @accepted_nested_attributes ||= []
        end

        def accepts_nested_attributes_for(*nested_attributes)
          @accepted_nested_attributes ||= []
          nested_attributes.each do |attr|
            @accepted_nested_attributes << attr.to_s
          end
        end
      end

      def assign_nested_attributes(key, value)

        unless self.class.modelClass.accepted_nested_attributes.include?(key.to_s) #&& has_relationship?(key)
          raise ArgumentError, "No association found for name '#{key}' in model '#{self.entity.name}'. Have you set `accepts_nested_attributes_for :#{key}` in the parent model?"
        end

        relation = self.relationships[key.to_s]
        klass = Object.const_get(relation.destinationEntity.managedObjectClassName)

        if relation.isToMany && value.is_a?(Array)
          assign_nested_attributes_for_collection_association(key, value, klass)
        elsif !relation.isToMany && value.is_a?(Hash)
          assign_nested_attributes_for_one_to_one_association(key, value, klass)
        else
          raise ArgumentError, "Cannot assign #{key} an attribute of class '#{value.class.name}'"
        end
      end

      def assign_nested_attributes_for_one_to_one_association(association_name, attributes, association_class)
        attributes = attributes.stringify_keys
        obj = association_class.new_with_context(attributes, self.managedObjectContext)
        self.setValue(obj, forKey:association_name)
      end

      def assign_nested_attributes_for_collection_association(association_name, attributes_collection, association_class)

        unless attributes_collection.is_a?(Array)
          raise ArgumentError, "Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
        end

        attributes_collection.each do |attributes|
          attributes = attributes.stringify_keys if attributes.respond_to?(:stringify_keys)
          obj = association_class.new_with_context(attributes, self.managedObjectContext)
          self.mutableSetValueForKey(association_name).addObject(obj)
        end
      end
    end
  end
end
