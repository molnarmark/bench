module Bench
  struct Token
    property tokenType : Symbol
    property value : String
    property line : Int32
    property col : Int32

    def initialize(@tokenType, @value, @line, @col)
    end
  end
end
