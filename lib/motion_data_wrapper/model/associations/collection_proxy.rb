module MotionDataWrapper
  class Model < NSManagedObject
    module Association
      class CollectionProxy
        def initialize(model, name, description)
          @model = model
          @klass = Kernel.const_get(description.destinationEntity.managedObjectClassName)
          @name = name
          @description = description
          self
        end

        def inspect
          to_a.to_s
        end

        def to_a
          if @model.valueForKey(@name)
            Array(@model.valueForKey(@name).allObjects)
          else
            []
          end
        end
        alias to_ary to_a

        def << (*records)
          local_records = records_in_local_context(records)
          @model.mutableSetValueForKey(@name).addObjectsFromArray(local_records)
          # Since the added records are likely in a different context,
          # refresh then so their relationship value is updated
          #
          # task = Task.create(title: "lol")
          # author  = Author.create(name: "John")

          # author.tasks << task
          # author.tasks
          # task.author => This would not get updated if we dont refresh the object
          records.flatten.map(&:refresh)
          self
        end

        def delete(*records)
          if records.first == :all
            to_ary.map(&:destroy)
          else
            objs = find(*records)
            objs.each do |o|
              o.destroy
            end
          end
          @model.save!
          @model.managedObjectContext.refreshObject(@model, mergeChanges:true)
        end
        alias :destroy :delete

        def writer(*records)
          records = records_in_local_context(records)
          @model.mutableSetValueForKey(@name).setSet(NSSet.setWithArray(records))
        end

        def clear
          @model.mutableSetValueForKey(@name).removeAllObjects
          @model.save!
        end

        def empty?
          to_a.empty?
        end

        def size
          to_a.count
        end
        alias count size

        def first
          to_a.first
        end

        def last
          to_a.last
        end

        def find(object_id)
          send("find_by_#{@klass.primary_key}", object_id)
        end

        def where(opts = nil, *rest)
          return self if opts.nil?
          new_predicate = PredicateBuilder.build_predicate(opts, rest, @klass)
          Array(@model.mutableSetValueForKey(@name).filteredSetUsingPredicate(new_predicate).allObjects)
        end

        def exists?
          !empty?
        end

        def build(attributes = nil)
          klass = Kernel.const_get(@description.destinationEntity.managedObjectClassName)
          obj = klass.new_with_context(attributes, @model.managedObjectContext)
          @model.mutableSetValueForKey(@name).addObject(obj)
          obj
        end

        def create(attributes = nil)
          klass = Kernel.const_get(@description.destinationEntity.managedObjectClassName)
          obj = klass.new_with_context(attributes, @model.managedObjectContext)
          @model.mutableSetValueForKey(@name).addObject(obj)
          @model.save!
          obj
        end

        def ==(other)
          to_ary == records_in_local_context(other)
        end

        private
        # Retrieve selected records in the local context of @model.
        # Save the records if they are not previously persisted so that we can retrieve them.
        def records_in_local_context(*records)
          records.flatten.map do |record|
            record.save! if !record.persisted?
            object_in_local_context = @model.managedObjectContext.objectWithID(record.objectID)
          end
        end

        def method_missing(method, *args, &block)
          if method.start_with?("find_by_")
            attribute = method.gsub("find_by_", "").gsub("!", "")

            if @klass.has_attribute? attribute
              chain = where("#{attribute} = ?", *args)
              if method.end_with?("!")
                chain.first!
              else
                chain.first
              end
            else
              super
            end

          elsif method.start_with?("find_all_by_")
            attribute = method.gsub("find_all_by_", "")

            if @klass.has_attribute? attribute
              where("#{attribute} = ?", *args).to_a
            else
              super
            end

          else
            super
          end
        end

        def valueForKey(key)
          willAccessValueForKey(key)
          tmp = primitiveValueForKey(key)
          didAccessValueForKey(key)
          tmp
        end
      end
    end
  end
end
