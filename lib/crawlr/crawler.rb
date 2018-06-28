module Crawlr
  class Crawler
    attr_reader :web_site

    def initialize(web_site)
      @web_site = web_site
    end

    def start
      first_visit!

      while web_site.web_pages.initial.exists?
        record = web_site.web_pages.initial.order(id: :desc).first
        Crawler::PageCrawler.new(web_site: web_site, web_page: record).process
      end

      puts "Done"
    end

    private

    def first_visit!
      web_page = web_site.web_pages.find_or_create_by!(http_method: 'get', url: web_site.uri.to_s)
      Crawler::PageCrawler.new(web_site: web_site, web_page: web_page).process unless web_page.done?
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
