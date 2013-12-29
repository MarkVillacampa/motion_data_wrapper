module MotionDataWrapper
  class Model < NSManagedObject
    module NestedAttributes

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        @@accepted_nested_attributes = []

        def accepted_nested_attributes
          @@accepted_nested_attributes
        end

        def accepts_nested_attributes_for(*nested_attributes)
          nested_attributes.each do |attr|
            @@accepted_nested_attributes << attr.to_s
          end
        end
      end

      def assign_nested_attributes(key, value)

        unless self.class.accepted_nested_attributes.include?(key.to_s) && has_relationship?(key)
          raise ArgumentError, "No association found for name '#{key}'."
        end

        relation = self.relationships[key.to_s]
        klass = Kernel.const_get(relation.destinationEntity.managedObjectClassName)

        if relation.isToMany && value.is_a?(Array)
          assign_nested_attributes_for_collection_association(key, value, klass)
        elsif !relation.isToMany && value.is_a?(Hash)
          assign_nested_attributes_for_one_to_one_association(key, value, klass)
        else
          raise ArgumentError, "Cannot assign #{key} an attribute of class '#{value.class.name}'"
        end
      end

      def assign_nested_attributes_for_one_to_one_association(association_name, attributes, association_class)
        existing_record = valueForKey(association_name)
        primary_key = association_class.primary_key
        attributes = attributes.stringify_keys

        if attributes[primary_key] && existing_record && (existing_record.valueForKey(primary_key) == attributes[primary_key])
          existing_record.assign_attributes(attributes)
        # Right now, if the atributes include a primary key but ti does not correspond with the current record, we create a new record.
        # TODO: find a better way to include primary keys here
        # elsif attributes[primary_key] != nil
        #   raise RecordNotFound, "Couldn't find #{association_name} with #{primary_key}=#{attributes[primary_key]} for #{self}"
        else
          if existing_record && existing_record.new_record?
            existing_record.assign_attributes(attributes)
          else
            method = "build_#{association_name}"
            if self.respond_to?(method)
              send(method, attributes)
            else
              raise ArgumentError, "Cannot build association '#{association_name}'"
            end
          end
        end
      end

      def assign_nested_attributes_for_collection_association(association_name, attributes_collection, association_class)

        unless attributes_collection.is_a?(Array)
          raise ArgumentError, "Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
        end

        association = send(association_name)
        primary_key = association_class.primary_key

        attributes_collection.each do |attributes|
          attributes = attributes.stringify_keys if attributes.respond_to?(:stringify_keys)

          # Right now, if the atributes include a primary key but it does not correspond with any of the current records, we create a new record.
          # TODO: find a better way to include primary keys here
          if attributes[primary_key] != nil && (existing_record = association.find(attributes[primary_key]))
            existing_record.assign_attributes(attributes)
          else
            association.build(attributes)
          # else
          #   raise RecordNotFound, "Couldn't find #{association_name} with #{primary_key}=#{attributes[primary_key]} for #{self}"
          end
        end
      end
    end
  end
end