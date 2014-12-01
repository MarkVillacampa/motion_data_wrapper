describe 'MotionDataWrapper::Model context support' do
  before do
    @second_context = NSManagedObjectContext.alloc.init
    @second_context.persistentStoreCoordinator = MotionDataWrapper.persistentStoreCoordinator

    # Add a task to the main context, just don't save the context
    # If saved, then @second_context would have the task from the persistent store
    @task = Task.new_with_context({}, MotionDataWrapper.managedObjectContext)
  end

  after do
    MotionDataWrapper.clean_data
  end

  describe '#with_context' do
    it "should return task from second context only" do
      Task.with_context(@second_context).all.should.be.empty

      new_task = Task.new_with_context({}, @second_context)

      Task.with_context(@second_context).all.should.be == [new_task]
      Task.limit(1).with_context(@second_context).all.should.be == [new_task]
    end
  end
end
