module Crawlr
  module Keyboard
    def self.ask?(message)
      puts message
      print('Done? y/n : ')

      while input = STDIN.gets
        if input =~ /^y(?:es)?$/i
          return true
        elsif input =~ /^n(?:o)?$/i
          return false
        else
          STDERR.puts('Please input y or n')
        end
      end
    end
  end
end
