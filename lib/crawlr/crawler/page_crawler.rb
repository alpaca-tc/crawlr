module Crawlr
  class Crawler
    class PageCrawler
      attr_reader :web_site, :web_page, :skipped

      delegate_missing_to :current_session

      def initialize(web_site:, web_page:)
        @web_site = web_site
        @web_page = web_page
        @skipped = false
      end

      def process
        return if web_page.done?

        web_site.ignore_path_patterns.reload

        unless web_site.ignore_path_patterns.overflowed?(web_page.url)
          create_web_page_session!
          return if skipped
        end

        web_site.ignore_path_patterns.overflowed!(web_page.url)
        web_page.done!
      end

      private

      def create_web_page_session!
        return if web_page.web_page_session

        Crawlr.debugger.debug("Crawlering #{web_page.url}")

        visit(web_page.url) unless current_url == web_page.url

        # if redirected
        unless current_url.remove(%r{/$}) == web_page.url.remove(%r{/$})
          Crawlr.debugger.debug("redirected #{web_page.url} => #{current_url}")
          current_page = web_site.web_pages.find_or_initialize_by(http_method: 'get', url: current_url.remove(%r{/$}))
          current_page.update!(priority: Time.now.to_i, state: 'rerun')
          web_page.update!(priority: -Time.now.to_i)
          @skipped = true
          return
        end

        extract_web_pages!
        extract_forms!

        web_page.create_web_page_session!(title: title, html: html)
      end

      def extract_web_pages!
        nokogiri = Nokogiri::HTML.parse(html, nil)
        links = nokogiri.css('a')

        hrefs = links.map { |link| link.attributes['href']&.value }.compact.uniq
        own_hrefs = hrefs.select { |href| web_site.own_url?(href) }

        own_hrefs.each do |href|
          uri = URI.parse(href)
          uri.fragment = nil
          uri.scheme = web_site.protocol
          uri.host ||= web_page.uri.host

          page = web_site.web_pages.find_or_initialize_by(http_method: 'get', url: uri.to_s.remove(%r{/$}))
          page.save! unless page.done?
        end
      end

      def extract_forms!
        original_nokogiri = Nokogiri::HTML.parse(html, nil)
        forms = original_nokogiri.css('form')

        return if forms.empty?

        forms.each do |form|
          form_pattern = web_page.form_patterns.find_or_initialize_by(
            xpath: form.path,
            action: (form.attributes['action']&.value).to_s
          )

          next if form_pattern.persisted? && form_pattern.skipped?

          mark_element(form) do
            Crawlr.debugger.debug("Crawlering #{web_page.url} / #{form.path}")
            http_method = (form.attributes['method']&.value || 'get').underscore

            if form_pattern.persisted?
              next if web_site.ignore_path_patterns.overflowed!(current_url)

              form_pattern.params.each do |key, value|
                element = form.css(%Q!input[name="#{key}"]!).first
                set_element_value(element.path, value)
              end

              submit_element(form.path)

              web_site.web_pages.find_or_create_by!(http_method: http_method, url: current_url.remove(%r{/$})) if web_site.own_url?(current_url)
              return
            elsif Crawlr::Keyboard.ask?("If you want to inspect this form(#{form.path}), please input attributes.")
              inputs = form.css('input')

              params = inputs.map { |input|
                name = input.attributes["name"]&.value
                value = get_element_value(input.path)
                [name, value]
              }.to_h

              Crawlr.debugger.debug(params)

              form_pattern.update!(params: params)

              submit_element(form.path)

              # until Crawlr::Keyboard.ask?("Suceeded?")
              #   submit_element(form.path)
              # end

              # サブミット後のページ
              web_site.web_pages.find_or_create_by!(http_method: http_method, url: current_url.remove(%r{/$})) if web_site.own_url?(current_url)
              return
            else
              form_pattern.update!(skipped: true, params: {})
            end
          rescue
            binding.pry
            raise 'a'
          end
        end
      end

      def submit_element(xpath)
        evaluate_script(<<~JAVA_SCRIPT)
          (function() {
            // find element
            var element = document.evaluate(`#{xpath}`, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue
            if (element) {
              return element.submit();
            }
          })();
        JAVA_SCRIPT
      end

      def set_element_value(xpath, value)
        evaluate_script(<<~JAVA_SCRIPT)
          (function() {
            // find element
            var element = document.evaluate(`#{xpath}`, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue
            if (element) {
              element.value = `#{value}`;
            }
          })();
        JAVA_SCRIPT
      end

      def get_element_value(xpath)
        evaluate_script(<<~JAVA_SCRIPT)
          (function() {
            // find element
            var element = document.evaluate(`#{xpath}`, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue
            if (element) {
              return element.value;
            }
          })();
        JAVA_SCRIPT
      end

      def mark_element(element)
        original = evaluate_script(<<~JAVA_SCRIPT)
          (function() {
            // find element
            var element = document.evaluate(`#{element.path}`, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue

            if (element) {
              return element.getAttribute('style')
            }
          })();
        JAVA_SCRIPT

        evaluate_script(<<~JAVA_SCRIPT)
          (function() {
            // find element
            var element = document.evaluate(`#{element.path}`, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue

            if (element) {
              element.setAttribute('style', 'border: solid 2px red;')
              element.focus();
            }
          })();
        JAVA_SCRIPT

        yield
      ensure
        evaluate_script(<<~JAVA_SCRIPT)
          (function() {
            // find element
            var element = document.evaluate(`#{element.path}`, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue

            if (element) {
              element.setAttribute('style', `#{original}`)
            }
          })();
        JAVA_SCRIPT
      end

      def current_session
        Capybara.current_session
      end
    end
  end
end
