# Handles JSON encoding and decoding in a similar way Ruby 1.9 does.
module JSON

class ParserError < StandardError; end

# Parses a string or data object and converts it in data structure.
#
# @param [String, NSData] str_data the string or data to serialize.
# @raise [ParserError] If the parsing of the passed string/data isn't valid.
# @return [Hash, Array, NilClass] the converted data structure, nil if the incoming string isn't valid.
#
# TODO: support options like the C Ruby module does
def self.parse(str_data, &block)
  return nil unless str_data
  data = str_data.respond_to?(:to_data) ? str_data.to_data : str_data
  opts = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
  error = Pointer.new(:id)
  obj = NSJSONSerialization.JSONObjectWithData(data, options:opts, error:error)
  raise ParserError, error[0].description if error[0]
  if block_given?
    yield obj
  else
    obj
  end

end

def self.generate(obj)
  NSJSONSerialization.dataWithJSONObject(obj, options:0, error:nil).to_str
end

end

class MotionDataWrapper::FixtureNotLoaded < StandardError; end

def fixtures(*fixture_names)
  fixture_names.map(&:to_s).each do |name|
    class_name = name.camelize
    filePath = NSBundle.mainBundle.pathForResource("fixtures/#{name}", ofType:"json")
    raise MotionDataWrapper::FixtureNotLoaded, "Could not find fixture '#{name}'" unless filePath
    string = NSMutableString.stringWithContentsOfFile(filePath, encoding:NSUTF8StringEncoding)
    raise MotionDataWrapper::FixtureNotLoaded, "Could not read fixture '#{name}'" unless string
    json = JSON.parse(string.dup)
    raise MotionDataWrapper::FixtureNotLoaded, "Could not parse fixture '#{name}'" unless json
    klass = Object.const_get(class_name)
    klass.create!(json)
  end
end
