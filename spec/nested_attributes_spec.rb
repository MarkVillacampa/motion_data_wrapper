describe MotionDataWrapper::Model::NestedAttributes do

  before do
    fixtures :author
  end

  after do
    clean_core_data
  end

  it "should ceate an author with two tasks" do
    Author.count.should.be == 1
    Author.first.tasks.count.should.be == 2
    Task.count.should.be == 2
  end

  it "should correctly save associated objects" do
    author = Author.where("name = ?", "John").first
    author.tasks.count.should.be == 2
    Task.count.should.be == 2
  end

  it "should raise ArgumentError for nonexisting associations" do
    lambda {
      Author.accepts_nested_attributes_for :ukelele
      Author.create({ :ukelele => {} })
    }.should.raise(MotionDataWrapper::UnknownAttributeError)
  end

  it 'should assign attributes to existing to-many relationship' do
    author = Author.first
    author.assign_attributes(tasks: [{ id:1, title: "New Title"}])
    author.tasks.find_by_id(1).title.should == "New Title"
  end

  it 'should assign attributes to existing to-one relationship' do
    task = Task.first
    author = task.author
    task.assign_attributes(author: { id: 1, name: "Peter"})
    task.author.should == author
    task.author.name.should == "Peter"
    task.author.id.should == 1
  end

  # These two tests currently dont pass, because a new record is created if we mass a
  # primary key attribute which is not present in the relation.
  # This is because we want to be able to create records setting primary keys manually.

  # it 'should raise when assigning to inexistent to-one relationship' do
  #   lambda {
  #     Task.first.assign_attributes(author: { id: 67, name: "John" })
  #   }.should.raise(MotionDataWrapper::RecordNotFound)
  # end

  # it 'should raise when assigning to inexistent to-many relationship' do
  #   lambda {
  #     Author.first.assign_attributes(tasks: [{ id:67 }])
  #   }.should.raise(MotionDataWrapper::RecordNotFound)
  # end
end