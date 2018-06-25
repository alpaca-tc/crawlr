# frozen_string_literal: true

RSpec.describe Crawlr::Analyzer::FormAnalyzer do
  describe 'InstanceMethods' do
    describe '#analyze' do
      subject { instance.analyze(page) }

      let(:instance) { described_class.new(web_site: web_site) }
      let(:web_site) { Crawlr::WebSite.new(url: 'https://alpaca.tc') }
      let(:page) { Crawlr::Page.new(url: 'https://alpaca.tc', html: html) }
      let(:html) { File.read(File.join(root_directory, 'spec/fixtures/html/page.html')) }

      it do
        subject
        expect(web_site.models.size).to eq(2)
      end
    end
  end
end
