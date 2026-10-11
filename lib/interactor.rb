# frozen_string_literal: true

# Deprecated compatibility loader.
#
# require "interactor" loads BusinessCase so existing apps keep booting for
# this release. New code should require "business_case". This file will be
# removed in a later release.
require "business_case"
