module Bench
  BENCH_OPERATORS    = ['=', '+', '<', '-', '>']
  BENCH_PUNCTUATIONS = ['(', ')', '{', '}', ';', ':', '[', ']', ',']
  BENCH_KEYWORDS     = ["fn", "class", "for", "in", "if", "return", "init", "let"]

  class Lexer
    @input : String

    def initialize(input : String)
      @tokens = [] of Token
      @input = input + '\0'
      @pos = -1

      @line = 0
      @col = 0
    end

    def tokens
      @tokens
    end

    def lex
      current = lookahead()

      if current == '\n'
        next_token()
        lex()
      end

      if is_eof(current)
        @tokens << Token.new(:EOF, "\0", @line, @col)
        return
      end

      if current == '"'
        @tokens << read_string
        lex()
      end

      # Identifier can't start with a number.
      if !is_number(current)
        if is_identifier(current)
          @tokens << read_identifier
          lex()
        end
      end

      if is_number(current)
        @tokens << read_number
        lex()
      end

      if is_operator(current)
        @tokens << read_operator
        lex()
      end

      if is_whitespace(current)
        next_token()
        lex()
      end

      if is_punc(current)
        tok = Token.new(:PUNCTUATION, current.to_s, @line, @col)
        @tokens << tok
        next_token()
        lex()
      end
    end

    def next_token
      @pos += 1
      next_char = @input[@pos].as(Char)

      if (next_char == '\n')
        @line += 1
        @col = 0
      else
        @col += 1
      end

      next_char
    end

    def peek
      @input[@pos].as(Char)
    end

    def lookahead
      next_index = @pos + 1
      @input[next_index].as(Char)
    end

    def is_operator(char : Char)
      BENCH_OPERATORS.includes?(char)
    end

    def is_whitespace(char : Char)
      char == ' ' || char == '\t'
    end

    def is_eof(char : Char)
      char == '\0'
    end

    def is_number(char : Char)
      begin
        char.to_i
        true
      rescue
        false
      end
    end

    def is_punc(char : Char)
      BENCH_PUNCTUATIONS.includes?(char)
    end

    def is_identifier(char : Char)
      !is_operator(char) && !is_whitespace(char) && !is_punc(char) && char != '\n' && char != '"'
    end

    def is_keyword(str : String)
      BENCH_KEYWORDS.includes?(str)
    end

    def read_identifier
      identifier = ""
      while is_identifier(lookahead())
        identifier += next_token()
      end

      if is_keyword(identifier)
        Token.new(:KEYWORD, identifier, @line, @col)
      else
        Token.new(:IDENTIFIER, identifier, @line, @col)
      end
    end

    def read_operator
      operator = ""

      while is_operator(lookahead())
        operator += next_token()
      end

      Token.new(:OPERATOR, operator, @line, @col)
    end

    def read_number
      number = ""
      while is_number(lookahead())
        number += next_token()
      end

      Token.new(:NUMBER, number, @line, @col)
    end

    def read_string
      # Skipping the opening quote
      next_token()
      string = ""
      while lookahead() != '"'
        string += next_token()
      end

      # Skipping the closing quote
      next_token()
      Token.new(:STRING, string, @line, @col)
    end
  end
end
