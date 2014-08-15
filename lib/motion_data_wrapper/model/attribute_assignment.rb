module MotionDataWrapper
  class Model < NSManagedObject
    module AttributeAssignment
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
      end

      def assign_attributes(new_attributes={})
        new_attributes = new_attributes.stringify_keys if new_attributes.respond_to?(:stringify_keys)

        new_attributes.each do |key, value|

          unless has_attribute?(key) || has_relationship?(key)
            raise UnknownAttributeError.new(self.class, key)
          end

          if attribute_alias?(key)
            key = attribute_alias(key)
          end

          if has_relationship?(key)
            if (value.is_a?(Hash) || value.is_a?(Array))
              assign_nested_attributes(key, value)
            else
              setValue(value, forKey:key)
            end
          else
            # TODO: Manage more possibly problematic `attributeType`s
            # and extract this somewhere else
            if self.attributes[key.to_s].attributeType == NSDateAttributeType && !value.class.ancestors.include?(NSDate)
              value = Time.iso8601_with_timezone(value)
            end
            setValue(value, forKey:key)
          end
        end
      end
    end
  end
end
