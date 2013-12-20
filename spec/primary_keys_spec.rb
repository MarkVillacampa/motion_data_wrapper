describe "MotionDataWrapper::Model::AttributeMethods::PrimaryKey" do

  after do
    clean_core_data
  end

  it "should override primary key" do
    Task.primary_key.should.be == "title"
  end

  it "should fetch tasks by its primary key" do
    task = Task.create(title: "Task1")
    Task.find("Task1").should.be == task
  end

end