# frozen_string_literal: true

module Crawlr
  class Page
    attr_reader :url, :html

    def initialize(url:, html:)
      @url = url
      @html = html
    end

    def nokogiri
      @nokogiri ||= Nokogiri::HTML.parse(@html, nil)
    end
  end
end
