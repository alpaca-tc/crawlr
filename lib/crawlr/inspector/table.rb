module Crawlr
  class Inspector
    class Table
      attr_reader :table_name, :attributes, :has_one, :has_many, :belongs_to

      def initialize(table_name)
        @table_name = table_name
        @attributes = Set.new
        @has_one    = Set.new
        @has_many   = Set.new
        @belongs_to = Set.new
      end

      def ==(other)
        table_name == other.table_name
      end

      def no_data?
        [
          @attributes,
          @has_one,
          @has_many,
          @belongs_to
        ].all?(&:blank?)
      end
    end
  end
end
