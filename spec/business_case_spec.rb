# frozen_string_literal: true

describe BusinessCase do
  include_examples :lint

  describe "nested call!" do
    let(:inner) do
      Class.new do
        include BusinessCase

        def call
          context.fail!(error: "inner failed", errors: ["inner failed"], note: "from inner")
        end
      end
    end

    let(:previous_step) { double("previous step") }

    let(:outer) do
      inner_case = inner
      step = previous_step
      Class.new do
        include BusinessCase

        define_method(:call) do
          context.started = true
          context.called!(step)
          inner_case.call!(step: "separate")
        end
      end
    end

    it "fails the outer context, keeps its keys, and rolls it back" do
      expect(previous_step).to receive(:rollback).once

      result = outer.call

      expect(result).to be_failure
      expect(result.started).to eq(true)
      expect(result.error).to eq("inner failed")
      expect(result.errors).to eq(["inner failed"])
      expect(result.note).to eq("from inner")
      expect(result.to_h).not_to have_key(:step)
    end

    it "does not replace keys the outer already set" do
      inner_case = inner
      preserving = Class.new do
        include BusinessCase

        define_method(:call) do
          context.started = true
          context.error = "outer reason"
          inner_case.call!(step: "separate")
        end
      end

      result = preserving.call

      expect(result).to be_failure
      expect(result.started).to eq(true)
      expect(result.error).to eq("outer reason")
      expect(result.errors).to eq(["inner failed"])
    end

    it "raises call! with the outer context and keeps the inner failure as cause" do
      allow(previous_step).to receive(:rollback)

      expect { outer.call! }.to raise_error(BusinessCase::Failure) { |error|
        expect(error.context).to be_failure
        expect(error.context.started).to eq(true)
        expect(error.context.error).to eq("inner failed")
        expect(error.context).not_to equal(error.cause.context)
        expect(error.cause.context.error).to eq("inner failed")
        expect(error.cause.context.step).to eq("separate")
      }
    end
  end

  describe "nested call" do
    it "stays successful when the inner result is ignored" do
      inner = Class.new do
        include BusinessCase

        def call
          context.fail!(error: "inner failed")
        end
      end

      outer = Class.new do
        include BusinessCase
      end
      outer.define_method(:call) do
        context.started = true
        inner.call(step: "separate")
      end

      result = outer.call

      expect(result).to be_success
      expect(result.started).to eq(true)
      expect(result.to_h).not_to have_key(:error)
      expect(result.to_h).not_to have_key(:step)
    end
  end

  describe "organizer with a shared context" do
    let(:inner) do
      Class.new do
        include BusinessCase

        def call
          context.fail!(error: "inner failed")
        end
      end
    end

    let(:organizer) do
      inner_case = inner
      Class.new do
        include BusinessCase::Organizer

        organize inner_case
      end
    end

    it "fails the same context the organizer was called with" do
      result = organizer.call(started: true)

      expect(result).to be_failure
      expect(result.started).to eq(true)
      expect(result.error).to eq("inner failed")
    end

    it "raises call! for that same context" do
      expect { organizer.call!(started: true) }.to raise_error(BusinessCase::Failure) { |error|
        expect(error.context.started).to eq(true)
        expect(error.context.error).to eq("inner failed")
        expect(error.cause).to be_nil
      }
    end
  end
end
