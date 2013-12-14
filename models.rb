class String
  def underscore
    word = self.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end

models = ['HoardedCat', 'Task', 'Post', 'Cloud', 'Tag', 'House', 'Human', 'Searchable', 'Resident', 'Event', 'Party', 'CatHoarder', 'StrictHuman', 'Child', 'Category', 'Meeting', 'Storm', 'Parent', 'Cat']

models.each do |model|
  File.open("app/#{model.underscore}.rb", "w") do |f|
    f.write("class #{model} < MotionDataWrapper::Model; end")
  end
end