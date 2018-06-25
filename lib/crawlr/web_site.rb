# frozen_string_literal: true

module Crawlr
  class WebSite
    attr_reader :url

    def initialize(url:)
      @url = url
    end

    def models
      @models ||= Hash.new do |hash, key|
        hash[key] = Crawlr::WebSite::Model.new(model_name: key)
      end
    end
  end
end
