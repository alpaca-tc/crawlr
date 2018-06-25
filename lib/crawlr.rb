# frozen_string_literal: true

require 'active_support'
require 'active_support/dependencies'

ActiveSupport::Dependencies.autoload_paths.unshift(__dir__)
ActiveSupport::Dependencies.hook!

require 'crawlr/version'
require 'nokogiri'

module Crawlr
  # Your code goes here...
end
