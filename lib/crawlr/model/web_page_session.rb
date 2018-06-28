require 'active_record'

module Crawlr
  module Model
    class WebPageSession < ApplicationRecord
      belongs_to :web_page, class_name: 'Crawlr::Model::WebPage'

      def nokogiri
        @nokogiri ||= Nokogiri::HTML.parse(html, nil)
      end
    end
  end
end
