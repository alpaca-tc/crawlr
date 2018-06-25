# frozen_string_literal: true

module Crawlr
  class WebSite
    class Model
      attr_accessor :model_name
      attr_reader :attributes

      def initialize(model_name:)
        @model_name = model_name
        @attributes = Set.new
      end
    end
  end
end
