module MotionDataWrapper
  class Model < NSManagedObject
    include CoreData
    include FinderMethods
    include Persistence
    include Validations
    include AttributeMethods
    include AttributeMethods::PrimaryKey
    include NestedAttributes
    include AttributeAssignment
    include Association

    def self.inherited(subclass)
      subclass.generate_association_methods if subclass.entity_description
      super
    end

    def inspect
      properties = []
      entity.properties.select { |p| p.is_a?(NSAttributeDescription) }.each do |property|
        properties << "#{property.name}: #{valueForKey(property.name).inspect}"
      end

      "#<#{entity.name} #{properties.join(", ")}>"
    end

    # If we try to compare the same object stored in different
    # NSMAnagedObjectContexts using #== it will fail.
    #
    # Example of failing scenario:
    #
    # task = Task.new({title: "Task1"})
    # task.save
    # task_saved = Task.all.last
    # puts task == task_saved => false
    #
    # This is because `task` represents the instance of Task stored in its
    # temporal NSManagedObjectContext, while `task_saved` represents
    # that instance of Task fetched in the main NSManagedObjectContext
    #
    # In order to compare two instances of an NSManagedObject in different
    # contexts we must then fetch them in the main NSManagedObjectContext
    # and compare them
    #
    def ==(model)
      if model.respond_to?(:objectID)
        error = Pointer.new(:object)
        App.delegate.managedObjectContext.objectWithID(self.objectID).isEqual(App.delegate.managedObjectContext.objectWithID(model.objectID))
      else
        super
      end
    end
    alias :eql? :==

    def valueForKey(key)
      willAccessValueForKey(key)
      tmp = primitiveValueForKey(key)
      didAccessValueForKey(key)
      tmp
    end

  end
end
