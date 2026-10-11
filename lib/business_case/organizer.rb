# frozen_string_literal: true

module BusinessCase
  # Public: BusinessCase::Organizer methods. Because BusinessCase::Organizer is a
  # module, custom BusinessCase::Organizer classes should include
  # BusinessCase::Organizer rather than inherit from it.
  #
  # Examples
  #
  #   class MyOrganizer
  #     include BusinessCase::Organizer
  #
  #     organize ActorOne, ActorTwo
  #   end
  module Organizer
    # Internal: Install BusinessCase::Organizer's behavior in the given class.
    def self.included(base)
      base.class_eval do
        include BusinessCase::Base

        extend ClassMethods
        include InstanceMethods
      end
    end

    # Internal: BusinessCase::Organizer class methods.
    module ClassMethods
      # Public: Declare BusinessCases to be invoked as part of the
      # BusinessCase::Organizer's invocation. These actors are invoked in
      # the order in which they are declared.
      #
      # actors - Zero or more (or an Array of) BusinessCase classes.
      #
      # Examples
      #
      #   class MyFirstOrganizer
      #     include BusinessCase::Organizer
      #
      #     organize ActorOne, ActorTwo
      #   end
      #
      #   class MySecondOrganizer
      #     include BusinessCase::Organizer
      #
      #     organize [ActorThree, ActorFour]
      #   end
      #
      # Returns nothing.
      def organize(*actors)
        @organized = actors.flatten
      end

      # Internal: An Array of declared BusinessCases to be invoked.
      #
      # Examples
      #
      #   class MyOrganizer
      #     include BusinessCase::Organizer
      #
      #     organize ActorOne, ActorTwo
      #   end
      #
      #   MyOrganizer.organized
      #   # => [ActorOne, ActorTwo]
      #
      # Returns an Array of BusinessCase classes or an empty Array.
      def organized
        @organized ||= []
      end
    end

    # Internal: BusinessCase::Organizer instance methods.
    module InstanceMethods
      # Internal: Invoke the organized BusinessCases. A BusinessCase::Organizer is
      # expected not to define its own "#call" method in favor of this default
      # implementation.
      #
      # Returns nothing.
      def call
        self.class.organized.each do |actor|
          actor.call!(context)
        end
      end
    end
  end
end
