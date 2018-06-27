# frozen_string_literal: true

module Crawlr
  class Cli
    def self.run(argv)
      new(argv.clone).run
    end

    def initialize(argv)
      @argv = argv
    end

    def run
      web_site = Crawlr::WebSite.new(url: 'https://s2.kingtime.jp/')
      analyzer = Crawlr::Analyzer.new(web_site)

      files = Dir[File.expand_path('../../tmp/**/*.html', __dir__)]

      puts '== Analyze'
      files.each do |path|
        puts "Analyze #{path}"
        page = Crawlr::Page.new(url: '', html: File.read(path))
        analyzer.analyze(page)
      end

      puts '== Output'
      Crawlr::Output.new(web_site).print_all
    end
  end
end
