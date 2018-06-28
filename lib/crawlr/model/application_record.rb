require 'active_record'

module Crawlr
  module Model
    class ApplicationRecord < ActiveRecord::Base
      establish_connection(adapter: "sqlite3", database: File.expand_path('../../../tmp/crawlr', __dir__))

      self.abstract_class = true
      self.logger = Logger.new(STDOUT)
    end
  end
end
