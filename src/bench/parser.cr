module Bench
  class Parser
    def initialize(@tokens : Array(Token))
      @current_index = -1
    end

    def lookahead
      next_index = @current_index + 1
      @tokens[next_index]
    end

    def current
      @tokens[@current_index]
    end

    def is_eof
      lookahead().tokenType == :EOF
    end

    def get_next
      @current_index += 1
      @tokens[@current_index]
    end

    def parse
      parse_top_level
    end

    def parse_top_level
      top_level = TopLevel.new

      while !is_eof()
        parsed = parse_anything
        top_level.push parsed if parsed
      end
    end

    def parse_anything
      next_token = lookahead()
      if next_token.tokenType == :KEYWORD && next_token.value == "let"
        parse_var_decl
      elsif next_token.tokenType == :KEYWORD && next_token.value == "form"
        pp parse_form
      elsif next_token.tokenType == :KEYWORD && next_token.value == "ret"
        pp parse_ret
      end
    end

    def parse_form
      expect(:KEYWORD, "form")
      name = expect(:IDENTIFIER).value
      expect(:PUNCTUATION, "(")
      expect(:PUNCTUATION, ")")
      expect(:OPERATOR, "->")
      expect(:PUNCTUATION, "{")

      body = Array(BenchASTNode).new

      # Parse the body until the closing }
      while lookahead().value != "}"
        parsed = parse_anything()
        body << parsed if parsed
      end

      expect(:PUNCTUATION, "}")

      FormDeclaration.new(name, body)
    end

    def parse_ret
      expect(:KEYWORD, "ret")
      value = expect(:IDENTIFIER).value
      expect(:PUNCTUATION, ";")
      RetStatement.new(value)
    end

    def parse_var_decl
      expect(:KEYWORD, "let")
      name = expect(:IDENTIFIER).value
      expect(:OPERATOR, "=")
      value = parse_expression().as(TokenValue)
      expect(:PUNCTUATION, ";")
      VariableDeclaration.new(name, value)
    end

    def parse_expression
      lookahead_token = lookahead()
      if lookahead_token.tokenType == :NUMBER
        parse_binary
      end
    end

    def parse_binary
      next_token = get_next
      binary_op_tokens = Array(Token).new
      op_stack = Array(String).new

      while next_token.value != ";"
        binary_op_tokens << next_token
        next_token = get_next
      end

      infix = ""
      binary_op_tokens.each do |token|
        if is_operator(token.value)
          while token.value != "^" && op_stack.size > 0 && (OPERATOR_PRECEDENCE[token.value] <= OPERATOR_PRECEDENCE[op_stack[op_stack.size - 1]])
            infix += op_stack.pop + " "
          end

          op_stack << token.value
        else
          infix += token.value + " "
        end
      end
      while op_stack.size > 0
        infix += op_stack.pop
      end

      @current_index -= 1
      BinaryExpression.new(infix)
    end

    def expect(tokenType : Symbol)
      lookahead_token = lookahead()
      if lookahead_token.tokenType == tokenType
        get_next
      else
        raise Exception.new("Expected #{tokenType.to_s}, got #{lookahead_token.value.to_s}")
      end
    end

    def expect(tokenType : Symbol, tokenValue : String)
      lookahead_token = lookahead()
      if lookahead_token.tokenType == tokenType && lookahead_token.value == tokenValue
        get_next
      else
        raise Exception.new("Expected #{tokenValue}, got #{lookahead_token.value.to_s}")
      end
    end

    def expect_any(tokenTypes : Array(Symbol))
      found_expected = nil
      tokenTypes.each do |tokenType|
        begin
          found_expected = expect(tokenType)
        rescue
        end
      end

      if found_expected
        found_expected
      else
        raise Exception.new("Expected any of #{tokenTypes.to_s}")
      end
    end

    def is_operator(char : String)
      begin
        OPERATOR_PRECEDENCE[char]
        true
      rescue
        false
      end
    end
  end
end
