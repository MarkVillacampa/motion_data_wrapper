module MotionDataWrapper
  class Relation < NSFetchRequest
    module Persistence

      def destroy_all
        all.each do |object|
          context.deleteObject(object)
        end

        save_context_and_parents!
      end

      def save_context_and_parents
        error = Pointer.new(:object)
        failed = false

        self.context.performBlockAndWait(lambda {
          unless context.save(error)
            p error.value.description
            context.deleteObject(self)
            failed = true
          end

          @current_saving_context = context.parentContext

          while @current_saving_context
            @current_saving_context.performBlockAndWait(
              proc {
                unless @current_saving_context.save(error)
                  p error.value.description
                  @current_saving_context.deleteObject(self)
                  failed = true
                end

                @current_saving_context = @current_saving_context.parentContext
              }
            )
          end
        })

        if failed
          raise MotionDataWrapper::RecordNotSaved, self and return false
        else
          return true
        end
      end

      def save_context_and_parents!
        begin
          save_context_and_parents
        rescue MotionDataWrapper::RecordNotSaved
          return false
        end
        true
      end

    end
  end
end
