module MotionDataWrapper
  class Relation < NSFetchRequest
    include CoreData
    include FinderMethods

    def initWithClass(klass)
      if init
        self.entity = klass.entity_description
        @model_class = klass
      end
      self
    end
  end
end
