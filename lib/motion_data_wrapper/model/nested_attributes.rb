module MotionDataWrapper
  class Model < NSManagedObject
    module NestedAttributes

      def assign_nested_attributes(key, value)
        return unless relation = self.entity.relationshipsByName[key.to_s]

        insert_in_context(temp_context)

        klass = Kernel.const_get(relation.destinationEntity.name)

        if relation.isToMany && value.is_a?(Array)
          assign_nested_attributes_for_collection_association(key, value, klass)
        elsif value.is_a?(Hash)
          assign_nested_attributes_for_one_to_one_association(key, value, klass)
        end
      end

      def assign_nested_attributes_for_one_to_one_association(key, value, klass)
        obj = klass.new(v)
        obj.insert_in_context(temp_context)
        setValue(obj, forKey: key)
      end

      def assign_nested_attributes_for_collection_association(key, values, klass)
        values.each do |v|
          obj = klass.new(v)
          obj.insert_in_context(temp_context)
          mutableSetValueForKey(key).addObject(obj)
        end
      end

      def temp_context
        @temp_context ||= begin
          ctx = NSManagedObjectContext.alloc.initWithConcurrencyType(NSPrivateQueueConcurrencyType)
          ctx.parentContext = App.delegate.managedObjectContext
        end
      end

    end
  end
end