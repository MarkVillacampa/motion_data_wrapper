module MotionDataWrapper
  class Model < NSManagedObject
    module AttributeMethods
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        @@attribute_aliases = {}

        # NOTE: Aliases are only taken into account when initializing a new object.
        # Additionally, no proxy methods are created for there attribute aliases

        # Allows you to make aliases for attributes.
        def alias_attribute(new_name, old_name)
          @@attribute_aliases.merge!({new_name.to_s => old_name.to_s})
        end

        # Returns the hash containing the aliases
        def attribute_aliases
          @@attribute_aliases
        end

        # Is +new_name+ an alias?
        def attribute_alias?(new_name)
          @@attribute_aliases.key? new_name
        end

        # Returns the original name for the alias +name+
        def attribute_alias(name)
          @@attribute_aliases[name]
        end
      end

    end
  end
end