module MotionDataWrapper
  class Relation < NSFetchRequest
    include CoreData
    include FinderMethods
    include Persistence

    def initWithClass(klass)
      if init
        self.entity = klass.entity_description
        @klass = klass
      end
      self
    end
  end
end
