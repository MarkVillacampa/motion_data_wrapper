module MotionDataWrapper
  class Relation < NSFetchRequest
    module CoreData

      def inspect
        to_a
      end

      def to_a
        error_ptr = Pointer.new(:object)
        #
        # The returned value from `executeFetchRequest:error:` is an NSArray
        # Most of the time RubyMotion treats NSArray and pure ruby Arrays the same way,
        # however in this case we want the array to be a pure ruby Array, so that array
        # comparison can be done via its members #== method
        #
        # We need this so that comparison between arrays of NSManagedObjects
        # fire our custom MotionDataWrapper::Model#== method
        #
        # This is the scenario when Array() is not called here:
        #
        # task = Task.create
        # task == Task.all.first  => true
        # Task.all.first == task  => true
        # [task] == Task.all      => false
        #
        # Internally, Task.all is a NSArray, but Array(Task.all) is a ruby Array
        #
        Array(context.executeFetchRequest(self, error:error_ptr))
      end

      private

      def context
        @ctx || App.delegate.managedObjectContext
      end
    end
  end
end
