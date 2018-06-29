module Crawlr
  module Keyboard
    def self.ask?(message)
      return true if File.exist?('/tmp/skip')
      puts message
      print('Done? y/n : ')

      while input = STDIN.gets
        if input =~ /^y(?:es)?$/i
          return true
        elsif input =~ /^n(?:o)?$/i
          return false
        elsif input =~ /d/
          binding.pry
        else
          STDERR.puts('Please input y or n')
        end
      end
    end
  end
end
