module MotionDataWrapper
  class PredicateBuilder
    # Used by #where #not and #or to build a predicate
    def self.build_predicate(opts, rest, klass)
      return nil if opts.nil?
      case opts
      when String
        if rest.is_a?(Array)
          rest = self.retrieve_objects_in_local_context(rest)
          new_predicate = NSPredicate.predicateWithFormat(opts.gsub("?", "%@"), argumentArray:rest)
        else
          new_predicate = NSPredicate.predicateWithFormat(opts)
        end
      when Hash
        new_predicate = self.build_predicate_from_hash(opts, klass)
      end
      new_predicate
    end

    # Builds a NSPredicate from a hash of attributes. Used for the Hash variant of #build_predicate
    def self.build_predicate_from_hash(args, klass)
      preds = []
      pred_opt = []

      args.each_pair do |key, value|
        raise UnknownAttributeError.new(klass, key) unless klass.has_attribute?(key)

        if klass.attribute_alias?(key)
          key = klass.attribute_alias(key)
        end

        if klass.has_relationship?(key)
          if value.is_a?(Hash)
            value.each_pair do |k, v|
              preds << "#{key}.#{k} = %@"
              pred_opt << v
            end
          elsif value.is_a?(NSManagedObject)
            preds << "#{key} = %@"
            pred_opt << retrieve_objects_in_local_context(value)
          end
        else
          preds << "#{key} = %@"
          pred_opt << value
        end
      end
      return nil if preds.empty?

      pred_str = preds.join(' AND ')
      NSPredicate.predicateWithFormat(pred_str, argumentArray:pred_opt)
    end

    # Given a NSManagedObject or an Array of values, retrieves the object in the current
    # context of the relation. This is needed to use related objects in a predicate:
    #
    #    author = Author.take
    #    Task.where(author: author)
    #    NSPredicate.predicateWithFormat("author = %@", author)
    #
    def self.retrieve_objects_in_local_context(args)
      if args.is_a? Array
        args.map do |v|
          v.is_a?(NSManagedObject) ? App.delegate.managedObjectContext.objectWithID(v.objectID) : v
        end
      elsif args.is_a? NSManagedObject
        App.delegate.managedObjectContext.objectWithID(args.objectID)
      else
        args
      end
    end
  end
end