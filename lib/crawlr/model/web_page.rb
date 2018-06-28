require 'active_record'

module Crawlr
  module Model
    class WebPage < ApplicationRecord
      belongs_to :web_site, class_name: 'Crawlr::Model::WebSite'
      has_one :web_page_session, class_name: 'Crawlr::Model::WebPageSession'
      has_many :form_patterns, class_name: 'Crawlr::Model::FormPattern'

      enum state: [:initial, :done]
      enum http_method: [:get, :post, :put, :delete], _prefix: 'http_method'

      def uri
        URI.parse(url)
      end
    end
  end
end
