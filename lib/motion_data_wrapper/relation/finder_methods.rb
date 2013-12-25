module MotionDataWrapper
  class Relation < NSFetchRequest
    module FinderMethods

      attr_accessor :where_hash

      def all
        to_a
      end

      def count
        return to_a.count if fetchOffset > 0
        old_result_type = self.resultType
        self.resultType = NSCountResultType
        count = to_a[0]
        self.resultType = old_result_type
        return count
      end

      def destroy_all
        all.map &:destroy
      end

      def empty?
        self.count == 0
      end

      def except(query_part)
        case query_part.to_sym
         when :where
           self.predicate = nil
         when :order
           self.sortDescriptors = nil
         when :limit
           self.fetchLimit = 0
         else
           raise ArgumentError, "unsupport query part '#{query_part}'"
         end
         self
      end

      def exists?
        !empty?
      end

      def first
        take
      end

      def first!
        take!
      end

      def last
        self.fetchOffset = self.count - 1 unless self.count < 1
        take
      end

      def last!
        last or raise RecordNotFound
      end

      def limit(l)
        l = l.to_i
        raise ArgumentError, "limit '#{l}' cannot be less than zero. Use zero for no limit." if l < 0
        self.fetchLimit = l
        self
      end

      def offset(o)
        o = o.to_i
        raise ArgumentError, "offset '#{o}' cannot be less than zero." if o < 0
        self.fetchOffset = o
        self
      end

      def order(column, opts={})
        descriptors = sortDescriptors.nil? ? [] : sortDescriptors.mutableCopy
        descriptors << NSSortDescriptor.sortDescriptorWithKey(column.to_s, ascending:opts.fetch(:ascending, true))
        self.sortDescriptors = descriptors
        self
      end

      def pluck(column)
        self.resultType = NSDictionaryResultType

         attribute_description = entity.attributesByName[column]
         raise ArgumentError, "#{column} not a valid column name" if attribute_description.nil?

         self.propertiesToFetch = [attribute_description]
         to_a.collect { |r| r[column] }
      end

      def reorder(*args)
        except(:order).order(*args)
      end

      def take
        limit(1).to_a[0]
      end

      def take!
        take or raise RecordNotFound
      end

      def uniq
        self.returnsDistinctResults = true
        self
      end

      # Returns a new relation, which is the result of filtering the current relation
      # according to the conditions in the arguments.
      #
      # The generated NSPredicate for each of the examples is shown below.
      #
      # It is recommended that you read the official documentation on Predicate Format String Syntax
      # https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html
      #
      # #where accepts conditions in one of several formats.
      #
      # === string
      #
      # A single string, without additional parameters will create a NSPredicate directly using
      # the #predicateWithFormat: method.
      #
      #    Task.where("title contains 'First Task'")
      #    NSPredicate.predicateWithFormat("title contains 'First Task'")
      #
      # === array
      #
      # If an array is passed, then the first element of the array is treated as a template, and
      # the remaining elements are inserted into the template to generate the condition.
      # Elements are inserted into the string in the order in which they appear.
      #
      #    Task.where("title = ? and due = ?", "First Task", NSDate.date)
      #    NSPredicate.predicateWithFormat("title = %@ and due = %@", "First Task", NSDate.date)
      #
      # === hash
      #
      # #where will also accept a hash condition, in which the keys are fields and the values
      # are values to be searched for.
      #
      # Fields can be symbols or strings. Values can be single values, arrays, or ranges.
      #
      #    Task.where({ title: "First Task", due: NSDate.date })
      #    NSPredicate.predicateWithFormat("title = %@ and due = %@", "First Task", NSDate.date)
      #
      #    Task.where({ title: ["First Task", "Second Task"]})
      #    NSPredicate.predicateWithFormat("name IN %@", ["First Task", "Second Task"])
      #
      #    Task.where({ created_at: (Time.now - 60*60*24)..Time.now })
      #    NSPredicate.predicateWithFormat("due BETWEEN %@", [(Time.now - 60*60*24), Time.now])
      #
      # In the case of a to-one relationship, a previously retrieved object (or its object ID)
      # can be passed as an argument
      #
      #    author = Author.take
      #    Task.where(author: author)
      #    NSPredicate.predicateWithFormat("author = %@", author)
      #
      # === Joins
      #
      # You may create a condition which uses any of the relationships of the model.
      #
      # For string and array conditions, use the relationship name in the condition.
      #
      #    Task.where("author.name = ?", "John")
      #    NSPredicate.predicateWithFormat("author.name = %@", "John")
      #
      # For hash conditions, you can either use the table name in the key, or use a sub-hash.
      #
      #    Task.where({ "author.name" => "John" })
      #    Task.where({ author: { name: "John" } })
      #
      # === no argument
      #
      # If no argument is passed, #where returns the current relation, that
      # can be chained with #not to return a new relation that negates the where clause.
      # #not can be called directly, this is just to behave like ActiveRecord.
      #
      #    User.where.not(name: "John")
      #    NSPredicate.predicateWithFormat("NOT name = %@", "John")
      #
      # === blank condition
      #
      # If the condition is any blank-ish object, then #where is a no-op and returns
      # the current relation.
      def where(opts = nil, *rest)
        return self if opts.nil?
        self.where_hash.merge!(opts) if opts.is_a?(Hash)
        new_predicate = build_predicate(opts, rest)
        add_predicate(new_predicate, :and)
        self
      end

      def not(opts, *rest)
        new_predicate = build_predicate(opts, rest)
        add_predicate(new_predicate, :not)
        self
      end

      # TODO test this
      def or(opts, *rest)
        new_predicate = build_predicate(opts, rest)
        add_predicate(new_predicate, :or)
        self
      end

      def first_or_create(attributes = {}, &block)
        first || @klass.create(self.where_hash.merge(attributes), &block)
      end

      def first_or_create!( attributes = {}, &block)
        first || @klass.create!(self.where_hash.merge(attributes), &block)
      end

      def first_or_initialize(attributes = {}, &block)
        first || @klass.new(self.where_hash.merge(attributes), &block)
      end

      def with_context(ctx)
        @ctx = ctx
        self
      end

      def where_hash
        @where_hash ||= {}
      end

      private
      # Given a NSManagedObject or an Array of values, retrieves the object in the current
      # context of the relation. This is needed to use related objects in a predicate:
      #
      #    author = Author.take
      #    Task.where(author: author)
      #    NSPredicate.predicateWithFormat("author = %@", author)
      #
      def retrieve_objects_in_local_context(args)
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

      COMPOUND_PREDICATE_TYPES = {
                                  :not => NSNotPredicateType,
                                  :and => NSAndPredicateType,
                                  :or  => NSOrPredicateType
                                 }.freeze

      # Adds a predicate by appending a predicate to the current one
      def add_predicate(new_predicate, type = :and)
        return if new_predicate == nil
        predicates = []
        # The new predicate must be 2nd in the array, as it will be prepended by NOT, AND or OR.
        predicates << self.predicate if self.predicate
        case type
        when :not
          new_predicate = NSCompoundPredicate.notPredicateWithSubpredicate(new_predicate)
          predicates << new_predicate
          self.predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
        when :and, :or
          ns_type = COMPOUND_PREDICATE_TYPES[type]
          predicates << new_predicate
          self.predicate = NSCompoundPredicate.alloc.initWithType(ns_type, subpredicates: predicates)
        end
      end

      # Used by #where #not and #or to build a predicate
      def build_predicate(opts, rest)
        return nil if opts.nil?
        case opts
        when String
          if rest.is_a?(Array)
            rest = retrieve_objects_in_local_context(rest)
            new_predicate = NSPredicate.predicateWithFormat(opts.gsub("?", "%@"), argumentArray:rest)
          else
            new_predicate = NSPredicate.predicateWithFormat(opts)
          end
        when Hash
          new_predicate = build_predicate_from_hash(opts)
        end
        new_predicate
      end

      # Builds a NSPredicate from a hash of attributes. Used for the Hash variant of #build_predicate
      def build_predicate_from_hash(args)
        preds = []
        pred_opt = []

        args.each_pair do |key, value|
          raise UnknownAttribute, key unless @klass.has_attribute?(key)

          if @klass.attribute_alias?(key)
            key = @klass.attribute_alias(key)
          end

          if @klass.has_relationship?(key)
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
    end
  end
end
