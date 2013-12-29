class Task < MotionDataWrapper::Model
  accepts_nested_attributes_for :author
  self.primary_key = "title"
end