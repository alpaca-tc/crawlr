require 'active_record'

module Crawlr
  module Model
    class IgnorePathPattern < ApplicationRecord
      belongs_to :web_site, class_name: 'Crawlr::Model::WebSite'

      def self.overflowed?(url)
        find { |record| record.regexp.match?(url.to_s) }&.overflowed?
      end

      def self.overflowed!(url)
        instance = find { |record| record.regexp.match?(url.to_s) }
        return false if instance.nil?

        instance.increment!(:count)
        instance.overflowed?
      end

      def regexp
        Regexp.new(regexp_string)
      end

      def overflowed?
        maximum_count <= count
      end
    end
  end
end
