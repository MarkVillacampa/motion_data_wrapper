describe MotionDataWrapper::Model::NestedAttributes do

  before do
    fixtures :author
  end

  after do
    clean_core_data
  end

  it "should ceate an author with two tasks" do
    Author.all.size.should.be == 1
    Author.first.tasks.allObjects.size.should.be == 2
    Task.all.size.should.be == 2
  end

  it "should correctly save associated objects" do
    author = Author.where("name = ?", "John").first
    author.tasks.allObjects.size.should.be == 2
    Task.all.should.be == Array(author.tasks.allObjects)
  end

  it "should raise ArgumentError for nonexisting associations" do
    lambda {
      Author.accepts_nested_attributes_for :ukelele
      Author.create({ :ukelele => {} })
    }.should.raise(MotionDataWrapper::UnknownAttribute)
  end

end