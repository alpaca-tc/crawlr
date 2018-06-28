require 'active_record'

module Crawlr
  module Model
    class WebSite < ApplicationRecord
      enum protocol: %w[https http]

      def uri
        @uri ||= URI.parse("#{protocol}://#{[host, path_prefix].join('/').remove(/\/$/)}")
      end
    end
  end
end
