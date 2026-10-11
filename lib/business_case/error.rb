# frozen_string_literal: true

module BusinessCase
  # Internal: Error raised during BusinessCase::Context failure. The error stores
  # a copy of the failed context for debugging purposes.
  class Failure < StandardError
    # Internal: Gets the BusinessCase::Context of the BusinessCase::Failure
    # instance. When this failure wraps a nested case, #cause is that case's
    # Failure and #context is the caller's context.
    attr_reader :context

    # Internal: Initialize a BusinessCase::Failure.
    #
    # context - A BusinessCase::Context to be stored within the
    #           BusinessCase::Failure instance. (default: nil)
    #
    # Examples
    #
    #   BusinessCase::Failure.new
    #   # => #<BusinessCase::Failure: BusinessCase::Failure>
    #
    #   context = BusinessCase::Context.new(foo: "bar")
    #   # => #<BusinessCase::Context foo="bar">
    #   BusinessCase::Failure.new(context)
    #   # => #<BusinessCase::Failure: #<BusinessCase::Context foo="bar">>
    #
    #   raise BusinessCase::Failure, context
    #   # => BusinessCase::Failure: #<BusinessCase::Context foo="bar">
    def initialize(context = nil)
      @context = context
      super
    end
  end
end
