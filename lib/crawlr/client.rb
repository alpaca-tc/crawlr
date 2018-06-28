require 'capybara'
require 'selenium-webdriver'

Capybara.register_driver :selenium do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 120 # instead of the default 60

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      chrome_options: {
        args: ['headless', 'window-size=1280,768'],
      },
    ),
    http_client: client,
  )
end

Capybara.javascript_driver = :selenium

module Crawlr
  class Client
  end
end
