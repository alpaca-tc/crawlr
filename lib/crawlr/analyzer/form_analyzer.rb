# frozen_string_literal: true

module Crawlr
  class Analyzer
    class FormAnalyzer < BaseAnalyzer
      def analyze(page)
        forms = page.nokogiri.css('form')

        forms.each do |form|
          analyze_form(form)
        end
      end

      private

      def analyze_form(form)
        inputs = form.css('input')
        names = inputs.map { |input| input.attributes['name']&.value }.compact
        names -= %w[utf8 _method authenticity_token commit]

        inference = Crawlr::Inference.new(form)
        inference.model_name

        attributes = web_site.models[inference.model_name].attributes
        names.each do |name|
          attributes.add(name)
        end
      end
    end
  end
end
