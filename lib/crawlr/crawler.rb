module Crawlr
  class Crawler
    attr_reader :web_site

    def initialize(web_site)
      @web_site = web_site
    end

    def start
      binding.pry
      raise NotImplementedError, 'no'
    end

    private

    def current_session
      Capybara.current_session
    end

    def method_missing(action, *args, &block)
      if current_session.respond_to?(action)
        current_session.public_send(action, *args, &block)
      else
        super
      end
    end
  end
end
