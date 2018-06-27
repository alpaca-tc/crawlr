# frozen_string_literal: true

module Crawlr
  class Output
    attr_reader :web_site

    def initialize(web_site)
      @web_site = web_site
    end

    def print_all
      web_site.models.values.each do |model|
        puts "[#{model.model_name}]"

        model.attributes.each do |name|
          puts name
        end

        puts ''
      end
    end
  end
end
