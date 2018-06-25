# frozen_string_literal: true

RSpec.describe Crawlr::WebSite do
  describe 'InstanceMethods' do
    describe '#url' do
      let(:instance) { described_class.new(url: url) }
      let(:url) { 'http://alpaca.tc' }
    end
  end
end
