# Changelog

## 1.0.0 / 2026-10-11

BusinessCase is a modernized fork of [collectiveidea/interactor](https://github.com/collectiveidea/interactor). This is the first release under the `business_case` name.

### New Features

* **Clean Architecture naming** - Gem `business_case`, module `BusinessCase`
* **Type-safe contracts** - Input validation with `expects` DSL
* **Output contracts** - Output validation with `ensures` DSL
* **Custom validators** - `format()`, `responds_to()`, `one_of()`, `in_range()`
* **Contract inheritance** - Contracts inherited from parent classes
* **Pattern matching** - `Context#deconstruct_keys`, including `success` and `failure` (from interactor 3.2.0)
* **Nested failures** - `call` re-raises a `Failure` that belongs to a different context (from interactor 3.2.0)
* **Backward compatibility** - `Interactor` is aliased to `BusinessCase` for this release, and `require "interactor"` still loads the library

### Breaking Changes

* Ruby 3.2+ required
* OpenStruct removed
* Custom Context implementation (API-compatible)
* No `ServiceActor` constant. That name belongs to the `service_actor` gem.

### Improvements

* Zero runtime dependencies
* GitHub Actions on Ruby 3.2, 3.3, 3.4, and 4.0
* Travis CI removed

---

## Historical Changelog (collectiveidea/interactor)

The following entries are from the original interactor gem:

### 3.1.0 / 2014-10-13

* [FEATURE] Add around hooks

### 3.0.1 / 2014-09-09

* [ENHANCEMENT] Add TomDoc code documentation

### 3.0.0 / 2014-09-07

* [FEATURE] Remove "magical" access to the context through the interactor
* [FEATURE] Manage context values via setters/getters rather than hash access
* [FEATURE] Change the primary interactor API method from "perform" to "call"
* [FEATURE] Return the mutated context rather than the interactor instance
* [FEATURE] Replace interactor setup with before and after hooks
* [FEATURE] Abort execution immediately upon interactor failure
* [ENHANCEMENT] Build a suite of realistic integration tests
* [ENHANCEMENT] Move rollback responsibility into the context

### 2.1.1 / 2014-09-30

* [FEATURE] Halt performance if the interactor fails prior
* [ENHANCEMENT] Add support for Ruby 2.1

### 2.1.0 / 2013-09-05

* [FEATURE] Roll back when an interactor within an organizer raises an error
* [BUGFIX] Ensure that context-deferred methods respect string keys
* [FEATURE] Respect context initialization from an indifferent access hash

### 2.0.1 / 2013-08-28

* [BUGFIX] Allow YAML (de)serialization by fixing interactor allocation

### 2.0.0 / 2013-08-19

* [BUGFIX] Fix rollback behavior within nested organizers
* [BUGFIX] Skip rollback for the failed interactor

### 1.0.0 / 2013-08-17

* Initial release!
