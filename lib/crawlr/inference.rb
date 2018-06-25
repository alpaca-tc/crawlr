# frozen_string_literal: true

module Crawlr
  class Inference
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def model_name
      (from_url || from_input)&.classify
    end

    private

    def from_url
      url = node.attributes['action']&.value
      return unless url

      uri = URI.parse(url)
      resources = uri.path.split('/').reject(&:blank?)

      ignore_resources = [
        /^edit$/,
        /^new$/,
        /^\d+$/
      ]

      resources.reverse.find do |resource|
        ignore_resources.none? { |matcher| matcher =~ resource }
      end
    rescue URI::InvalidURIError
      nil
    end

    def from_input
      binding.pry
      raise 'a'
    end
  end
end
