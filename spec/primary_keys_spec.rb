describe "MotionDataWrapper::Model::AttributeMethods::PrimaryKey" do

  after do
    MotionDataWrapper.clean_data
  end

  it "should override primary key" do
    Task.primary_key = "title"
    Task.primary_key.should.be == "title"
    Task.primary_key = "id"
  end

  it "should fetch tasks by its primary key" do
    task = Task.create(title: "Task1")
    Task.find("Task1").should.be == task
  end

end
