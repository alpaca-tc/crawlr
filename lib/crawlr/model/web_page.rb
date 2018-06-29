require 'active_record'

module Crawlr
  module Model
    class WebPage < ApplicationRecord
      belongs_to :web_site, class_name: 'Crawlr::Model::WebSite'
      has_one :web_page_session, class_name: 'Crawlr::Model::WebPageSession', dependent: :destroy
      has_many :form_patterns, class_name: 'Crawlr::Model::FormPattern', dependent: :destroy

      enum state: [:initial, :done, :rerun]
      enum http_method: [:get, :post, :put, :delete], _prefix: 'http_method'

      scope :jobs, -> { where(state: [:initial, :rerun]).order(priority: :desc, id: :desc) }

      def uri
        URI.parse(url)
      end

      def url=(value)
        super(value.to_s.remove(%r{/$}))
      end
    end
  end
end
