require 'active_record'

module Crawlr
  module Model
    class PathPattern < ApplicationRecord
      belongs_to :web_site, class_name: 'Crawlr::Model::WebSite'
    end
  end
end
