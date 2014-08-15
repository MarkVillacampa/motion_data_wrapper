module MotionDataWrapper
  class Model < NSManagedObject
    module Association

      def self.included(base)
        base.extend(ClassMethods)
      end

      def collection_proxy_cache
        @collection_proxy_cache ||= {}
      end

      module ClassMethods
        def generate_association_methods
          relationships.each do |name, description|
            if description.isToMany
              generate_methods_for_collection_association(name, description)
            else
              generate_methods_for_to_one_association(name, description)
            end
          end
        end

        def generate_methods_for_collection_association(name, description)
          self.send(:define_method, name, lambda {
            collection_proxy_cache[name] ||= CollectionProxy.new(self, name, description)
          })

          self.send(:define_method, "#{name}=", lambda { |value|
            collection_proxy_cache[name] ||= CollectionProxy.new(self, name, description)
            collection_proxy_cache[name].writer(value)
          })
        end

        def generate_methods_for_to_one_association(name, description)
          # If the object we are setting has already been persisted we retrieve it in the local context.
          # If the object we are setting has not been persisted, we clone it and delete it from its local context.
          self.send(:define_method, "#{name}=", lambda { |value|
            if value.nil?
              setValue(nil, forKey: name)
            else
              value.save! if !value.persisted?
              object_in_local_context = self.managedObjectContext.objectWithID(value.objectID)
              setValue(object_in_local_context, forKey: name)
            end
          })

          self.send(:define_method, "build_#{name}", lambda { |attributes|
            klass = Object.const_get(description.destinationEntity.managedObjectClassName)
            obj = klass.new_with_context(attributes, self.managedObjectContext)
            setValue(obj, forKey: name)
            obj
          })

          self.send(:define_method, "create_#{name}", lambda{ |attributes|
            klass = Object.const_get(description.destinationEntity.managedObjectClassName)
            obj = klass.new_with_context(attributes, self.managedObjectContext)
            setValue(obj, forKey: name)
            save!
            obj
          })
        end
      end
    end
  end
end
