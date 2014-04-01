describe MotionDataWrapper::Model::Association do

  before do
    @task = Task.create! title: "First Task", id: 1
    @author = Author.create! name: "John"
  end

  after do
    clean_core_data
  end

  describe 'to-one associations' do
    it 'should set an association in a persisted object from a non-persisted object' do
      author = Author.new(name: "John")
      @task.author = author
      @task.save!
      @task.author.persisted?.should == true
      Author.last == @task.author
      retrieved_task = Task.find_by_id(1)
      retrieved_task.author.should.be == @task.author
      retrieved_task.author.name.should.be == "John"
    end

    it 'should set an association in a persisted object from a persisted object' do
      author = Author.create(name: "John")
      @task.author = author
      @task.save!
      Author.last.should == author
      retrieved_task = Task.find_by_id(1)
      retrieved_task.author.should.be == author
      retrieved_task.author.name.should.be == "John"
    end

    it 'should set a nil value for an association' do
      @task.author = nil
      @task.save!
      retrieved_task = Task.find_by_id(1)
      retrieved_task.author.should.be == nil
    end

    it 'should build an association in a persisted object' do
      author = @task.build_author(name: "John")
      author.persisted?.should == false
      @task.save!
      Author.last == author
      author.persisted?.should == true
      retrieved_author = Task.find_by_id(1).author
      retrieved_author.name.should.be == "John"
      retrieved_author.should.be == author
    end

    it 'should create an association in a persisted object' do
      author = @task.create_author(name: "John")
      Author.last == author
      author.persisted?.should == true
      retrieved_author = Task.find_by_id(1).author
      retrieved_author.name.should.be == "John"
      retrieved_author.should.be == author
    end
  end

  describe 'to-many associations' do
    it 'should set an association in a persisted object from a non-persisted object' do
      task1 = Task.new title:"First"
      task2 = Task.new title:"Second"
      @author.tasks << [task1, task2]
      @author.tasks.size.should == 2
      @author.tasks.first.persisted?.should == true
      @author.tasks.last.persisted?.should == true
      @author.save!
    end

    it 'should set an association in a persisted object from a persisted object' do
      task1 = Task.create! title:"First"
      task2 = Task.create! title:"Second"
      @author.tasks << [task1, task2]
      @author.tasks.size.should == 2
      @author.save!
      # task1 and task2 are in a different context than @author, so we have to refresh them after save
      task1.refresh(true)
      task1.author.should == @author
      task2.refresh(true)
      task2.author.should == @author
    end

    it 'should build an association in a persisted object' do
      task = @author.tasks.build(title: "First", id: 67)
      task.persisted?.should == false
      @author.save!
      Task.last == task
      task.persisted?.should == true
      retrieved_author = Task.find_by_id(67).author
      retrieved_author.name.should.be == "John"
      retrieved_author.should.be == @author
    end

    it 'should create an association in a persisted object' do
      task = @author.tasks.create(title: "First", id: 67)
      Task.last == task
      task.persisted?.should == true
      retrieved_author = Task.find_by_id(67).author
      retrieved_author.name.should.be == "John"
      retrieved_author.should.be == @author
    end

    it 'should delete all objects in the association' do
      task = @author.tasks.create(title: "First", id: 67)
      Task.last.should == task
      task.persisted?.should == true
      @author.tasks.delete(:all)
      @author.tasks.empty?.should == true
      task.destroyed?.should == true
    end

    it 'should clear all objects in association but not delete them' do
      task = @author.tasks.create(title: "First", id: 67)
      Task.last.should == task
      @author.tasks.last.should == task
      task.persisted?.should == true
      task.deleted?.should == false
      @author.tasks.clear
      @author.tasks.empty?.should == true
      task.destroyed?.should == false
    end

    it 'should find task using #where with hash' do
      tasks = Task.create([{id:5, title:"First"},{id:6, title:"Second"}])
      @author.tasks = tasks
      @author.save!
      task = @author.tasks.where(id: 5).first
      task.title.should == "First"
    end

    it 'should find task using #where with array' do
      tasks = Task.create([{id:5, title:"First"},{id:6, title:"Second"}])
      @author.tasks = tasks
      @author.save!
      task = @author.tasks.where("title = ?", "First").first
      task.id.should == 5
    end

    it 'should find task using #find' do
      tasks = Task.create([{id:5, title:"First"},{id:6, title:"Second"}])
      @author.tasks = tasks
      @author.save!
      task = @author.tasks.find(5)
      task.title.should == "First"
    end

    it 'should find task using dynamic finders' do
      tasks = Task.create([{id:5, title:"First"},{id:6, title:"Second"}])
      @author.tasks = tasks
      @author.save!
      task = @author.tasks.find_by_id(5)
      task.title.should == "First"
    end
  end
end
