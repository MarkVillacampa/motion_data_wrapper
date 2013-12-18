module MotionDataWrapper
  class Model < NSManagedObject
    module NestedAttributes

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        @@accepted_nested_attributes = []

        def accepted_nested_attributes
          @@accepted_nested_attributes
        end

        def accepts_nested_attributes_for(*nested_attributes)
          nested_attributes.each do |attr|
            @@accepted_nested_attributes << attr.to_s
          end
        end
      end

      def assign_nested_attributes(key, value)

        unless self.class.accepted_nested_attributes.include?(key.to_s) && has_relationship?(key)
          raise ArgumentError, "No association found for name '#{key}'."
        end

        relation = self.relationships[key.to_s]
        klass = Kernel.const_get(relation.destinationEntity.managedObjectClassName)

        if relation.isToMany && value.is_a?(Array)
          assign_nested_attributes_for_collection_association(key, value, klass)
        elsif value.is_a?(Hash)
          assign_nested_attributes_for_one_to_one_association(key, value, klass)
        end
      end

      def assign_nested_attributes_for_one_to_one_association(key, value, klass)
        obj = klass.new_with_context(value, self.managedObjectContext)
        setValue(obj, forKey: key)
      end

      def assign_nested_attributes_for_collection_association(key, values, klass)
        values.each do |v|
          obj = klass.new_with_context(v, self.managedObjectContext)
          mutableSetValueForKey(key).addObject(obj)
        end
      end
    end
  end
end