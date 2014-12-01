# -*- coding: utf-8 -*-
describe MotionDataWrapper::Model do

  after do
    MotionDataWrapper.clean_data
  end

  it "should create and return task" do
    task = Task.create title:"Task1"
    task.entity.managedObjectClassName.should.be == "Task"
    Task.all.size.should == 1
  end

  it "should create and return an empty task" do
    task = Task.create
    task.entity.managedObjectClassName.should.be == "Task"
    Task.all.size.should == 1
  end

  it "should create and return 3 tasks" do
    tasks = Task.create [{title:"Task1"}, {title:"Task2"}, {title:"Task3"}]
    tasks.count.should.be == 3
    tasks.each { |t| t.entity.managedObjectClassName.should.be == "Task" }
    Task.all.size.should == 3
  end

  it "should create and return 3 empty tasks" do
    tasks = Task.create [{}, {}, {}]
    tasks.count.should.be == 3
    tasks.each { |t| t.entity.managedObjectClassName.should.be == "Task" }
    Task.all.size.should == 3
  end

  it "should not save an invalid record" do
    author = Author.create
    author.should.be == nil
    Author.all.size.should.be == 0
  end

  it "should not save an invalid record and raise" do
    lambda {
      author = Author.create!
      author.should.be == nil
    }.should.raise(MotionDataWrapper::RecordNotSaved)
  end

  it "#persisted? should return boolean" do
    task = Task.new title:"Task1"
    task.persisted?.should.be == false
    task.save!
    task.persisted?.should.be == true

    task = Task.first
    task.persisted?.should.be == true
    task.destroy
    task.persisted?.should.be == false
  end

  it "#destroyed? should return boolean" do
    task = Task.create title:"Task1"
    task.destroyed?.should.be == false
    task.save!
    task.destroyed?.should.be == false
    task.destroy
    task.destroyed?.should.be == true

    Task.create title:"Task1"
    task = Task.first
    task.destroyed?.should.be == false
    task.destroy
    task.destroyed?.should.be == true
  end

  it "#new_record? should return boolean" do
    task = Task.new title:"Task1"
    task.new_record?.should.be == true
    task.save!
    task.new_record?.should.be == false
    task.destroy
    task.new_record?.should.be == false

    Task.create title:"Task1"
    task = Task.first
    task.new_record?.should.be == false
    task.destroy
    task.destroyed?.should.be == true
  end

  it "should update various attribute and save" do
    task = Task.new(title: "Task1", authorName: "Author1")
    task.persisted?.should.be == false
    task.update_attributes(title: "Task2", authorName: "Author2")
    task.persisted?.should.be == true
    task.title.should.be == "Task2"
    task.authorName.should.be == "Author2"
  end

  it "should update one attribute and save" do
    cat = Task.new(title: "Task1", authorName: "Author1")
    cat.persisted?.should.be == false
    cat.update_attribute(:authorName, "Author2")
    cat.persisted?.should.be == true
    cat.authorName.should.be == "Author2"
  end

  it "should be stored to app support dir" do
    Task.create title:"Task1"
    manager = NSFileManager.defaultManager
    manager.fileExistsAtPath(MotionDataWrapper.sqlite_url.path).should == true
  end

end
