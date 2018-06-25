# frozen_string_literal: true

module Crawlr
  class Analyzer
    def self.registory
      @registry ||= []
    end

    def self.register(analyzer)
      registry.push(analyzer)
    end

    def initialize(web_site)
      @web_site = web_site
      @analyzers = self.class.registry.map { |analyzer| analyzer.new(web_site: web_site) }
    end

    def analyze(page)
      @analyzers.each do |analyzer|
        analyzer.analyze(page)
      end
    end
  end
end
