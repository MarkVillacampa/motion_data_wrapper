module MotionDataWrapper
  class Model < NSManagedObject
    module AttributeMethods

      def self.included(base)
        base.extend(ClassMethods)
      end

      # NOTE: Aliases are only taken into account when initializing a new object.
      # Additionally, no proxy methods are created for there attribute aliases

      module ClassMethods
        # Allows you to make aliases for attributes.
        def alias_attribute(new_name, old_name)
          @attribute_aliases ||= {}
          @attribute_aliases.merge!({new_name.to_s => old_name.to_s})
        end

        # Returns the hash containing the aliases
        def attribute_aliases
          @attribute_aliases ||= {}
        end

        # Is +new_name+ an alias?
        def attribute_alias?(new_name)
          @attribute_aliases ||= {}
          @attribute_aliases.key? new_name
        end

        # Returns the original name for the alias +name+
        def attribute_alias(name)
          @attribute_aliases[name]
        end

        def attribute_names
          @attribute_names ||= entity_description.propertiesByName.keys
        end

        def relationship_names
          @relationship_names ||= entity_description.relationshipsByName.keys
        end

        def attributes
          @attributes ||= entity_description.propertiesByName
        end

        def relationships
          @relationships ||= entity_description.relationshipsByName
        end

        # An attribute is valid if it is declared in the NSEntityDescription of the model or if there is a alias declared

        def has_attribute?(attribute)
          attribute_names.include?(attribute.to_s) || attribute_alias?(attribute.to_s)
        end

        def has_relationship?(attribute)
          relationship_names.include?(attribute.to_s)
        end
      end

      # Delegate instance methods to class method
      # TODO: find a cleaner way to do this

      def attribute_aliases
        self.class.modelClass.attribute_aliases
      end

      def attribute_alias?(new_name)
        self.class.modelClass.attribute_alias?(new_name)
      end

      def attribute_alias(name)
        self.class.modelClass.attribute_alias(name)
      end

      def attribute_names
        self.class.modelClass.attribute_names
      end

      def relationship_names
        self.class.modelClass.relationship_names
      end

      def attributes
        self.class.modelClass.attributes
      end

      def relationships
        self.class.modelClass.relationships
      end

      def has_attribute?(attribute)
        self.class.modelClass.has_attribute?(attribute)
      end

      def has_relationship?(attribute)
        self.class.modelClass.has_relationship?(attribute)
      end
    end
  end
end
