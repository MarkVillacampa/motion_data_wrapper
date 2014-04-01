module MotionDataWrapper
  class Model < NSManagedObject
    module Persistence

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def create(attributes = {}, &block)
          begin
            create!(attributes, &block)
          rescue MotionDataWrapper::RecordNotSaved
          end
        end

        def create!(attributes = {}, &block)
          if attributes.is_a?(Array)
            attributes.collect { |attr| create!(attr, &block) }
          else
            object = new(attributes)
            yield(object) if block_given?
            object.save!
            object
          end
        end

        def new(attributes = {}, &block)
          temp_context = NSManagedObjectContext.alloc.initWithConcurrencyType(NSPrivateQueueConcurrencyType)
          temp_context.undoManager = nil
          temp_context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
          temp_context.parentContext = App.delegate.managedObjectContext

          attributes = {} if attributes.nil?

          alloc.initWithEntity(entity_description, insertIntoManagedObjectContext:temp_context).tap do |model|
            model.instance_variable_set('@new_record', true)
            model.generate_association_methods
            model.assign_attributes(attributes)
            yield(model) if block_given?
          end
        end

        # This method is used when we instantiate a nested model in
        # MotionDataWrapper::Model::NestedAttributes to be included
        # in a relationship, it has to be inserted in its parent's
        # context rather than a new temp context
        def new_with_context(attributes={}, context=nil,&block)
          attributes = {} if attributes.nil?

          alloc.initWithEntity(entity_description, insertIntoManagedObjectContext:context).tap do |model|
            model.instance_variable_set('@new_record', true)
            model.generate_association_methods
            model.assign_attributes(attributes)
            yield(model) if block_given?
          end
        end
      end

      def update_attribute(name, value)
        assign_attributes(name => value)
        save
      end

      alias update_column update_attribute

      def update(attributes)
        assign_attributes(attributes)
        save
      end

      alias update_attributes update
      alias update_columns update

      def update!(attributes)
        assign_attributes(attributes)
        save!
      end

      alias update_attributes! update!

      def willAccessValueForKey(key)
        if !@association_methods_generated
          generate_association_methods
          @association_methods_generated = 1
        end
      end

      def awakeFromFetch
        super
        after_fetch if respond_to? :after_fetch
      end

      def awakeFromInsert
        super
        generate_association_methods
        after_fetch if respond_to? :after_fetch
      end

      # This method will be called once when the local child context is saved,
      #and again when the parent context is saved.
      # It is used to flag unsaved related objects as persisted when its parent
      # object is saved:
      #
      # task = Task.create(title: "First")
      # author = task.build_author(name: "John")
      # author.persisted?
      # => false
      # task.save
      # author.persisted?
      # => true
      #
      def didSave
        @new_record = false
      end

      def destroy
        before_destroy_callback

        context = self.managedObjectContext
        context.deleteObject(self)

        error = Pointer.new(:object)
        failed = false
        context.performBlockAndWait(lambda {
          unless context.save(error)
            context.deleteObject(self)
            failed = true
          end
          if parentContext = context.parentContext
            parentContext.performBlockAndWait(
              proc {
                unless parentContext.save(error)
                  parentContext.deleteObject(self)
                  failed = true
                end
              }
            )
          end
        })

        if failed
          return false
        end

        @destroyed = true
        after_destroy_callback
        freeze
        true
      end

      # WARNING: There is a `deleted?` method which is a convenient alias for
      # `isDeleted` provided by RubyMotion. This method is different.
      def destroyed?
        @destroyed || false
      end

      def new_record?
        @new_record || false
      end

      def persisted?
        !(new_record? || destroyed?)
      end

      def save
        begin
          save!
        rescue MotionDataWrapper::RecordNotSaved
          return false
        end
        true
      end

      def save!
        before_save_callback
        error = Pointer.new(:object)
        context = self.managedObjectContext
        failed = false
        context.performBlockAndWait(lambda {
          unless context.save(error)
            context.deleteObject(self)
            failed = true
          end
          if parentContext = context.parentContext
            parentContext.performBlockAndWait(
              proc {
                unless parentContext.save(error)
                  parentContext.deleteObject(self)
                  failed = true
                end
              }
            )
          end
        })

        if failed
          raise MotionDataWrapper::RecordNotSaved, self and return false
        end

        instance_variable_set('@new_record', false)
        after_save_callback

        true
      end

      def insert_in_context(context)
        context.insertObject(self)
        context
      end

      def refresh(merge = true)
        self.managedObjectContext.refreshObject(self, mergeChanges:merge)
      end

      private

      def before_save_callback
        before_save if respond_to? :before_save
        @is_new_record = new_record?
        if @is_new_record
          before_create if respond_to? :before_create
        else
          before_update if respond_to? :before_update
        end
      end

      def after_save_callback
        if @is_new_record
          after_create if respond_to? :after_create
        else
          after_update if respond_to? :after_update
        end
        after_save if respond_to? :after_save
      end

      def before_destroy_callback
        before_destroy if respond_to? :before_destroy
      end

      def after_destroy_callback
        after_destroy if respond_to? :after_destroy
      end
    end
  end
end
