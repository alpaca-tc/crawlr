require 'active_record'

module Crawlr
  module Model
    class FormPattern < ApplicationRecord
      belongs_to :web_page, class_name: 'Crawlr::Model::WebPage'

      serialize :params, JSON
    end
  end
end
