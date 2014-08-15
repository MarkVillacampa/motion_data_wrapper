module MotionDataWrapper

  class RecordInvalid < StandardError
    def initialize(record)
      @record = record
      @errors = @record.errors
      super(@errors.map { |k,v| "#{k} #{v}"}.join(', '))
    end
  end

  class RecordNotFound < StandardError
  end

  # Raised by `save!` and `create!` methods when record cannot be
  # saved because record is invalid.
  class RecordNotSaved < StandardError
    def initialize(record)
      @record = record
      @errors = @record.errors
      super(@errors.map { |k,v| "#{k} #{v}"}.join(', '))
    end
  end

  # Raised when unknown attributes are supplied via mass assignment.
  class UnknownAttributeError < NoMethodError

    attr_reader :record, :attribute

    def initialize(record, attribute)
      super("unknown attribute: #{attribute} for model #{record.entity.name}")
    end

  end

  class RecordNotFound < StandardError
  end

end
