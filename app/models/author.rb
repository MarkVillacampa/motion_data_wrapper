class Author < MotionDataWrapper::Model
  accepts_nested_attributes_for :tasks
end
