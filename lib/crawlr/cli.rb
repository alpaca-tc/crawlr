# frozen_string_literal: true

require 'pry'
require 'capybara'
require 'selenium-webdriver'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.default_driver = :selenium
Capybara.javascript_driver = :selenium

module Crawlr
  class Cli
    def self.run(argv)
      new(argv.clone).run
    end

    def initialize(argv)
      @argv = argv
    end

    def run
      case @argv.first
      when 'setup'
        load File.expand_path('script/setup.rb', __dir__)
      when 'clean'
        load File.expand_path('script/clean.rb', __dir__)
        load File.expand_path('script/setup.rb', __dir__)
      when 'start'
        url = @argv[1]
        web_site = Model::WebSite.from_url(url)
        web_site.save!

        Crawler.new(web_site).start
      when 'debug'
        binding.pry
      when 'ignore'
        regexp = @argv[1]
        web_site = Model::WebSite.first
        web_site.ignore_path_patterns.find_or_create_by!(regexp_string: regexp)
      when 'inspect'
        url = @argv[1]
        web_site = Model::WebSite.from_url(url)
        web_site.save!

        Inspector.new(web_site).start
      else
        raise NotImplementedError, 'unknown command given'
      end

      # web_site = Crawlr::WebSite.new(url: 'https://s2.kingtime.jp/')
      # analyzer = Crawlr::Analyzer.new(web_site)
      #
      # files = Dir[File.expand_path('../../tmp/**/*.html', __dir__)]
      #
      # puts '== Analyze'
      # files.each do |path|
      #   puts "Analyze #{path}"
      #   page = Crawlr::Page.new(url: '', html: File.read(path))
      #   analyzer.analyze(page)
      # end
      #
      # puts '== Output'
      # Crawlr::Output.new(web_site).print_all
    end
  end
end
