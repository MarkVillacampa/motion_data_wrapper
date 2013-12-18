module MotionDataWrapper
  class Model < NSManagedObject
    module NestedAttributes

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        @@accepted_nested_attributes = []

        def accepts_nested_attributes_for(*nested_attributes)
          nested_attributes.each do |attr|
            if has_relationship?(attr.to_s)
              @@accepted_nested_attributes << attr.to_s
            else
              raise ArgumentError, "No association found for name `#{association_name}'. Has it been defined yet?"
            end
          end
        end
      end

      def assign_nested_attributes(key, value)
        return unless @@accepted_nested_attributes.include?(key.to_s)

        relation = self.relationships[key.to_s]

        klass = Kernel.const_get(relation.destinationEntity.name)

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