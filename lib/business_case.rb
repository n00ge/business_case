# frozen_string_literal: true

require "business_case/context"
require "business_case/error"
require "business_case/hooks"
require "business_case/organizer"
require "business_case/contracts"

# Public: BusinessCase methods. Because BusinessCase is a module, custom BusinessCase
# classes should include BusinessCase rather than inherit from it.
#
# Examples
#
#   class MyActor
#     include BusinessCase
#
#     def call
#       puts context.foo
#     end
#   end
module BusinessCase
  # Public: Base module that provides core actor functionality.
  # This is automatically included when you include BusinessCase.
  module Base
    # Internal: Install BusinessCase's behavior in the given class.
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include Hooks

        # Public: Gets the BusinessCase::Context of the BusinessCase instance.
        attr_reader :context
      end
    end

    # Internal: BusinessCase class methods.
    module ClassMethods
      # Public: Invoke a BusinessCase. This is the primary public API method to an
      # actor.
      #
      # context - A Hash whose key/value pairs are used in initializing a new
      #           BusinessCase::Context object. An existing BusinessCase::Context may
      #           also be given. (default: {})
      #
      # Examples
      #
      #   MyActor.call(foo: "bar")
      #   # => #<BusinessCase::Context foo="bar">
      #
      #   MyActor.call
      #   # => #<BusinessCase::Context>
      #
      # Returns the resulting BusinessCase::Context after manipulation by the
      #   actor.
      def call(context = {})
        new(context).tap(&:run).context
      end

      # Public: Invoke a BusinessCase. The "call!" method behaves identically to
      # the "call" method with one notable exception. If the context is failed
      # during invocation of the actor, the BusinessCase::Failure is raised.
      #
      # context - A Hash whose key/value pairs are used in initializing a new
      #           BusinessCase::Context object. An existing BusinessCase::Context may
      #           also be given. (default: {})
      #
      # Examples
      #
      #   MyActor.call!(foo: "bar")
      #   # => #<BusinessCase::Context foo="bar">
      #
      #   MyActor.call!
      #   # => #<BusinessCase::Context>
      #
      #   MyActor.call!(foo: "baz")
      #   # => BusinessCase::Failure: #<BusinessCase::Context foo="baz">
      #
      # Returns the resulting BusinessCase::Context after manipulation by the
      #   actor.
      # Raises BusinessCase::Failure if the context is failed.
      def call!(context = {})
        new(context).tap(&:run!).context
      end
    end

    # Internal: Initialize a BusinessCase.
    #
    # context - A Hash whose key/value pairs are used in initializing the
    #           actor's context. An existing BusinessCase::Context may also be
    #           given. (default: {})
    #
    # Examples
    #
    #   MyActor.new(foo: "bar")
    #   # => #<MyActor @context=#<BusinessCase::Context foo="bar">>
    #
    #   MyActor.new
    #   # => #<MyActor @context=#<BusinessCase::Context>>
    def initialize(context = {})
      @context = Context.build(context)
    end

    # Internal: Invoke an actor instance along with all defined hooks. The
    # "run" method is used internally by the "call" class method. The following
    # are equivalent:
    #
    #   MyActor.call(foo: "bar")
    #   # => #<BusinessCase::Context foo="bar">
    #
    #   actor = MyActor.new(foo: "bar")
    #   actor.run
    #   actor.context
    #   # => #<BusinessCase::Context foo="bar">
    #
    # After successful invocation of the use case, the instance is tracked
    # within the context. If the context is failed or any error is raised, the
    # context is rolled back.
    #
    # A BusinessCase::Failure for this context is swallowed, which is what
    # makes BusinessCase.call return a failed context. A failure raised for a
    # different context is rolled back here and then re-raised.
    #
    # Returns nothing.
    # Raises BusinessCase::Failure when the failure belongs to another context.
    def run
      run!
    rescue Failure => error
      raise unless error.context.equal?(context)
    end

    # Internal: Invoke a BusinessCase instance along with all defined hooks. The
    # "run!" method is used internally by the "call!" class method. The following
    # are equivalent:
    #
    #   MyActor.call!(foo: "bar")
    #   # => #<BusinessCase::Context foo="bar">
    #
    #   actor = MyActor.new(foo: "bar")
    #   actor.run!
    #   actor.context
    #   # => #<BusinessCase::Context foo="bar">
    #
    # After successful invocation of the actor, the instance is tracked
    # within the context. If the context is failed or any error is raised, the
    # context is rolled back.
    #
    # The "run!" method behaves identically to the "run" method with one notable
    # exception. If the context is failed during invocation of the actor,
    # the BusinessCase::Failure is raised.
    #
    # Returns nothing.
    # Raises BusinessCase::Failure if the context is failed.
    def run!
      with_hooks do
        validate_input_contract! if respond_to?(:validate_input_contract!, true)
        call
        context.called!(self)
        validate_output_contract! if respond_to?(:validate_output_contract!, true)
      end
    rescue
      context.rollback!
      raise
    end

    # Public: Invoke a BusinessCase instance without any hooks, tracking, or
    # rollback. It is expected that the "call" instance method is overwritten for
    # each actor class.
    #
    # Returns nothing.
    def call
    end

    # Public: Reverse prior invocation of a BusinessCase instance. Any actor
    # class that requires undoing upon downstream failure is expected to overwrite
    # the "rollback" instance method.
    #
    # Returns nothing.
    def rollback
    end
  end

  # Internal: Install BusinessCase's behavior in the given class.
  def self.included(base)
    base.class_eval do
      include Base
    end
  end
end

# Backward compatibility for one release. Prefer BusinessCase in new code.
# There is no ServiceActor alias; that name belongs to another gem.
Interactor = BusinessCase
