describe "MotionDataWrapper::AttributeMethods support for aliases" do

  before do
    fixtures :human
  end

  after do
    clean_core_data
  end

  it "can write aliased attributes" do
    human = Human.all.first
    human.name.should.be == "Other"
  end

end