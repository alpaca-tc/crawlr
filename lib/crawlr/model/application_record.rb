require 'active_record'

module Crawlr
  module Model
    class ApplicationRecord < ActiveRecord::Base
      establish_connection(adapter: "sqlite3", database: 'crawlr')
      self.logger = Logger.new(STDOUT)
    end
  end
end
