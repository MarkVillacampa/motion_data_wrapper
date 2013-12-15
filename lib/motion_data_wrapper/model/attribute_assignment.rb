module MotionDataWrapper
  class Model < NSManagedObject
    module AttributeAssignment
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
      end

      def assign_attributes(attributes)
        attributes.each do |k, v|
          setValue(v, forKey:k)
        end
      end

    end
  end
end