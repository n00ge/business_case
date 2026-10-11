# frozen_string_literal: true

module BusinessCase
  # Public: The object for tracking state of a BusinessCase's invocation. The
  # context is used to initialize the actor with the information required
  # for invocation. The actor manipulates the context to produce the result
  # of invocation.
  #
  # The context is the mechanism by which success and failure are determined and
  # the context is responsible for tracking individual actor invocations
  # for the purpose of rollback.
  #
  # The context may be manipulated using arbitrary getter and setter methods.
  #
  # Examples
  #
  #   context = BusinessCase::Context.new
  #   # => #<BusinessCase::Context>
  #   context.foo = "bar"
  #   # => "bar"
  #   context
  #   # => #<BusinessCase::Context foo="bar">
  #   context.hello = "world"
  #   # => "world"
  #   context
  #   # => #<BusinessCase::Context foo="bar" hello="world">
  #   context.foo = "baz"
  #   # => "baz"
  #   context
  #   # => #<BusinessCase::Context foo="baz" hello="world">
  class Context
    # Internal: Initialize a new Context with the given attributes.
    #
    # attributes - A Hash of attributes to initialize the context with.
    #
    # Returns a new Context instance.
    def initialize(attributes = {})
      @table = {}
      attributes.each { |key, value| self[key] = value }
    end

    # Internal: Get the value of an attribute.
    #
    # key - The Symbol or String key of the attribute.
    #
    # Returns the value of the attribute or nil if not set.
    def [](key)
      @table[key.to_sym]
    end

    # Internal: Set the value of an attribute.
    #
    # key - The Symbol or String key of the attribute.
    # value - The value to set.
    #
    # Returns the value.
    def []=(key, value)
      @table[key.to_sym] = value
    end

    # Internal: Convert the context to a hash.
    #
    # Returns a Hash representation of the context.
    def to_h
      @table.dup
    end

    # Public: Support hash pattern matching on context attributes.
    #
    # Matches the behavior added to collectiveidea/interactor 3.2.0. success
    # and failure are included so a pattern can branch on the outcome.
    # Attribute order is not part of the contract, so array deconstruct is
    # intentionally not defined.
    #
    # keys - Attribute names named by the pattern, or nil for every attribute.
    #
    # Examples
    #
    #   context = BusinessCase::Context.new(foo: "bar")
    #   context => { foo:, success: }
    #   foo
    #   # => "bar"
    #
    # Returns a Hash of the requested attributes, plus success and failure
    # when those keys are requested or when keys is nil.
    def deconstruct_keys(keys)
      attributes = to_h.merge(success: success?, failure: failure?)
      keys.nil? ? attributes : attributes.slice(*keys)
    end

    # Internal: Iterate over each key-value pair in the context.
    #
    # Yields each key-value pair.
    #
    # Returns nothing.
    def each_pair(&block)
      @table.each_pair(&block)
    end

    # Internal: Check if the context responds to a method.
    #
    # method_name - The Symbol or String name of the method.
    # include_private - Whether to include private methods (default: false).
    #
    # Returns true if the method exists or is a dynamic getter/setter.
    def respond_to_missing?(method_name, include_private = false)
      true
    end

    # Internal: Handle dynamic getter and setter methods.
    #
    # method_name - The Symbol name of the method.
    # args - Arguments passed to the method.
    #
    # Returns the value for getters or sets the value for setters.
    def method_missing(method_name, *args)
      if method_name.to_s.end_with?("=")
        self[method_name.to_s.chomp("=")] = args.first
      else
        self[method_name]
      end
    end

    # Internal: Access the underlying hash table (for compatibility).
    #
    # Returns the internal hash table.
    def table
      @table
    end
    private :table

    # Internal: Provide modifiable access to the table (for compatibility).
    #
    # Returns the internal hash table.
    def modifiable
      @table
    end
    private :modifiable

    # Internal: Initialize a BusinessCase::Context or preserve an existing one.
    # If the argument given is a BusinessCase::Context, the argument is returned.
    # Otherwise, a new BusinessCase::Context is initialized from the provided
    # hash.
    #
    # The "build" method is used during actor initialization.
    #
    # context - A Hash whose key/value pairs are used in initializing a new
    #           BusinessCase::Context object. If an existing BusinessCase::Context
    #           is given, it is simply returned. (default: {})
    #
    # Examples
    #
    #   context = BusinessCase::Context.build(foo: "bar")
    #   # => #<BusinessCase::Context foo="bar">
    #   context.object_id
    #   # => 2170969340
    #   context = BusinessCase::Context.build(context)
    #   # => #<BusinessCase::Context foo="bar">
    #   context.object_id
    #   # => 2170969340
    #
    # Returns the BusinessCase::Context.
    def self.build(context = {})
      self === context ? context : new(context)
    end

    # Public: Whether the BusinessCase::Context is successful. By default, a new
    # context is successful and only changes when explicitly failed.
    #
    # The "success?" method is the inverse of the "failure?" method.
    #
    # Examples
    #
    #   context = BusinessCase::Context.new
    #   # => #<BusinessCase::Context>
    #   context.success?
    #   # => true
    #   context.fail!
    #   # => BusinessCase::Failure: #<BusinessCase::Context>
    #   context.success?
    #   # => false
    #
    # Returns true by default or false if failed.
    def success?
      !failure?
    end

    # Public: Whether the BusinessCase::Context has failed. By default, a new
    # context is successful and only changes when explicitly failed.
    #
    # The "failure?" method is the inverse of the "success?" method.
    #
    # Examples
    #
    #   context = BusinessCase::Context.new
    #   # => #<BusinessCase::Context>
    #   context.failure?
    #   # => false
    #   context.fail!
    #   # => BusinessCase::Failure: #<BusinessCase::Context>
    #   context.failure?
    #   # => true
    #
    # Returns false by default or true if failed.
    def failure?
      @failure || false
    end

    # Public: Fail the BusinessCase::Context. Failing a context raises an error
    # that may be rescued by the calling actor. The context is also flagged
    # as having failed.
    #
    # Optionally the caller may provide a hash of key/value pairs to be merged
    # into the context before failure.
    #
    # context - A Hash whose key/value pairs are merged into the existing
    #           BusinessCase::Context instance. (default: {})
    #
    # Examples
    #
    #   context = BusinessCase::Context.new
    #   # => #<BusinessCase::Context>
    #   context.fail!
    #   # => BusinessCase::Failure: #<BusinessCase::Context>
    #   context.fail! rescue false
    #   # => false
    #   context.fail!(foo: "baz")
    #   # => BusinessCase::Failure: #<BusinessCase::Context foo="baz">
    #
    # Raises BusinessCase::Failure initialized with the BusinessCase::Context.
    def fail!(context = {})
      context.each { |key, value| modifiable[key.to_sym] = value }
      @failure = true
      raise Failure, self
    end

    # Internal: Track that a BusinessCase has been called. The "called!" method
    # is used by the actor being invoked with this context. After an
    # actor is successfully called, the actor instance is tracked in
    # the context for the purpose of potential future rollback.
    #
    # actor - A BusinessCase instance that has been successfully called.
    #
    # Returns nothing.
    def called!(actor)
      _called << actor
    end

    # Public: Roll back the BusinessCase::Context. Any actors to which this
    # context has been passed and which have been successfully called are asked
    # to roll themselves back by invoking their "rollback" instance methods.
    #
    # Examples
    #
    #   context = MyActor.call(foo: "bar")
    #   # => #<BusinessCase::Context foo="baz">
    #   context.rollback!
    #   # => true
    #   context
    #   # => #<BusinessCase::Context foo="bar">
    #
    # Returns true if rolled back successfully or false if already rolled back.
    def rollback!
      return false if @rolled_back
      _called.reverse_each(&:rollback)
      @rolled_back = true
    end

    # Internal: An Array of successfully called BusinessCase instances invoked
    # against this BusinessCase::Context instance.
    #
    # Examples
    #
    #   context = BusinessCase::Context.new
    #   # => #<BusinessCase::Context>
    #   context._called
    #   # => []
    #
    #   context = MyActor.call(foo: "bar")
    #   # => #<BusinessCase::Context foo="baz">
    #   context._called
    #   # => [#<MyActor @context=#<BusinessCase::Context foo="baz">>]
    #
    # Returns an Array of BusinessCase instances or an empty Array.
    def _called
      @called ||= []
    end
  end
end
