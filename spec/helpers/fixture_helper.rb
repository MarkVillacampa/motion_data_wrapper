class MotionDataWrapper::FixtureNotLoaded < StandardError; end

def fixtures(*fixture_names)
  fixture_names.map(&:to_s).each do |name|
    class_name = name.camelize
    filePath = NSBundle.mainBundle.pathForResource("fixtures/#{name}", ofType:"json")
    raise MotionDataWrapper::FixtureNotLoaded, "Could not find fixture '#{name}'" unless filePath
    string = NSMutableString.stringWithContentsOfFile(filePath, encoding:NSUTF8StringEncoding)
    raise MotionDataWrapper::FixtureNotLoaded, "Could not read fixture '#{name}'" unless string
    json = BW::JSON.parse(string.dup)
    raise MotionDataWrapper::FixtureNotLoaded, "Could not parse fixture '#{name}'" unless json
    klass = Kernel.const_get(class_name)
    klass.create!(json)
  end
end