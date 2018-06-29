module Crawlr
  module Erd
    PATH = '/Users/alpaca-tc/src/erd/dist/build/erd/erd'

    def self.execute(input:, output:)
      system(PATH, '-i', input, '-o', output)
    end
  end
end
