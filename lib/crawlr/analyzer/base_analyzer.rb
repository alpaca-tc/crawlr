# frozen_string_literal: true

module Crawlr
  class Analyzer
    class BaseAnalyzer
      attr_reader :web_site

      def initialize(web_site:)
        @web_site = web_site
      end
    end
  end
end
