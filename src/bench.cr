# TODO: Write documentation for `Bench`
require "./bench/*"

module Bench
  VERSION = "0.1.0"
  # pp "function".as(Symbol)
  lexer = Bench::Lexer.new(File.read("test.bench"))
  lexer.lex

  parser = Bench::Parser.new(lexer.tokens)
  parser.parse
end
