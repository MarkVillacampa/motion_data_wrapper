module MotionDataWrapper
  class Model < NSManagedObject
    module AttributeAssignment
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
      end

      def assign_attributes(new_attributes)
        return if new_attributes.nil?

        new_attributes.each do |key, value|
          next unless has_attribute?(key)

          if attribute_alias?(key)
            key = attribute_alias(key)
          end

          if (value.is_a?(Hash) || value.is_a?(Array)) && has_relationship?(key)
            assign_nested_attributes(key, value)
          else
            # if self.attributes[key.to_s].attributeType == NSDateAttributeType
            #   value = Time.iso8601_with_timezone(value)
            # end
            setValue(value, forKey:key)
          end
        end
      end

    end
  end
end