module MotionDataWrapper
  class Model < NSManagedObject
    module CoreData

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        # Core Data dynamically creates subclasses of model classes in order to
        # add the property accessors. These subclasses are named after the user’s
        # class, but contain underscores.
        #
        # E.g. if the user’s model would be called `Author`, the dynamic subclass
        # would be called `Author_Author_`.
        def dynamicSubclass?
          @dynamicSubclass = name.include?('_') if @dynamicSubclass.nil?
          @dynamicSubclass
        end

        # Returns the model class as defined by the user, even if called on a
        # class dynamically defined by Core Data.
        def modelClass
          @modelClass ||= begin
            if dynamicSubclass?
              # TODO this will probably break if the user namespaces the model class
              Object.const_get(name.split('_').first)
            else
              self
            end
          end
        end

        # Returns the entity description from the model class as defined by the
        # user, even if called on a class dynamically defined by Core Data.
        def entity_description
          @_metadata ||= begin
            if dynamicSubclass?
              modelClass.entity_description
            else
              MotionDataWrapper.managedObjectModel.entitiesByName[name]
            end
          end
        end

        def clean_entity_description
          @_metadata = nil
        end
      end

    end
  end
end
