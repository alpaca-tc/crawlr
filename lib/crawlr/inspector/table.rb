module Crawlr
  class Inspector
    class Table
      attr_reader :table_name, :attributes

      def initialize(table_name)
        @table_name = table_name
        @attributes = Set.new
      end

      def ==(other)
        table_name == other.table_name
      end
    end
  end
end
