module MotionDataWrapper
  class Model < NSManagedObject
    module AttributeAssignment
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
      end

      def assign_attributes(new_attributes={})
        new_attributes.each do |key, value|
          unless has_attribute?(key)
            raise UnknownAttribute, key
          end

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