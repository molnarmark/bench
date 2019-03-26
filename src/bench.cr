require "./bench/*"
require "./targets/*"

module Bench
  VERSION = "0.1.0"

  lexer = Bench::Lexer.new(File.read("test.bench"))
  lexer.lex

  parser = Bench::Parser.new(lexer.tokens)
  top_level = parser.parse
  pp top_level
  # lua_target = Bench::Targets::Lua.new(top_level)
end
