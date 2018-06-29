require 'active_record'

module Crawlr
  module Model
    class FormPattern < ApplicationRecord
      belongs_to :web_page, class_name: 'Crawlr::Model::WebPage'

      serialize :params, JSON
    end

    def action=(value)
      super(value.to_s.remove(%r{/$}))
    end
  end
end
