# frozen_string_literal: true

describe BusinessCase do
  include_examples :lint

  describe ".call with nested failures" do
    let(:inner) do
      Class.new do
        include BusinessCase

        def call
          context.fail!(error: "inner")
        end
      end
    end

    it "re-raises a failure from a different context" do
      inner_case = inner
      outer = Class.new do
        include BusinessCase
      end
      outer.define_method(:call) { inner_case.call! }

      expect { outer.call }.to raise_error(BusinessCase::Failure) { |error|
        expect(error.context.error).to eq("inner")
      }
    end

    it "swallows a failure for the same context" do
      inner_case = inner
      outer = Class.new do
        include BusinessCase
      end
      outer.define_method(:call) { inner_case.call!(context) }

      result = outer.call

      expect(result).to be_failure
      expect(result.error).to eq("inner")
    end
  end
end
