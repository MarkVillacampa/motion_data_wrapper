module MotionDataWrapper
  class Model < NSManagedObject
    module AttributeMethods
      module PrimaryKey
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def primary_key
            @primary_key || 'id'
          end

          def primary_key=(primary_key)
            @primary_key = primary_key.to_s
          end
        end
      end
    end
  end
end
