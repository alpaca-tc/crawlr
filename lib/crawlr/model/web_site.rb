require 'active_record'

module Crawlr
  module Model
    class WebSite < ApplicationRecord
      has_many :web_pages, class_name: 'Crawlr::Model::WebPage'
      has_many :ignore_path_patterns, class_name: 'Crawlr::Model::IgnorePathPattern'
      has_many :form_patterns, through: :web_pages, source: :form_patterns

      enum protocol: %w[https http]

      def self.from_url(url)
        uri = URI.parse(url)
        Model::WebSite.find_or_initialize_by(protocol: uri.scheme, host: uri.host, path_prefix: uri.path)
      end

      def uri
        URI.parse("#{protocol}://#{[host, path_prefix].join('/').remove(/\/$/)}")
      end

      def own_url?(url)
        return unless valid_url?(url)

        target_uri = URI.parse(url)

        return false if target_uri.host.present? && uri.host != target_uri.host
        return false if target_uri.path.present? && !target_uri.path.start_with?(path_prefix)

        true
      end

      private

      def valid_url?(url)
        uri = URI.parse(url)
        uri.host = host
      rescue
        false
      end
    end
  end
end
