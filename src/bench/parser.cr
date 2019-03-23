module Bench
  class Parser
    def initialize(@tokens : Array(Token))
      @current_index = -1
    end

    def parse
      pp parse_top_level
    end

    private def lookahead
      next_index = @current_index + 1
      @tokens[next_index]
    end

    private def is_eof
      lookahead().tokenType == :EOF
    end

    private def get_next
      @current_index += 1
      @tokens[@current_index]
    end

    private def parse_top_level
      top_level = TopLevel.new

      while !is_eof()
        parsed = parse_anything.as(BenchASTNode)
        top_level.push parsed if parsed
      end

      top_level
    end

    # TODO write a separate method for this
    def parse_anything
      next_token = lookahead()

      if next_token.tokenType == :KEYWORD && next_token.value == "fn"
        return parse_function
      elsif next_token.tokenType == :KEYWORD && next_token.value == "let"
        return parse_var_decl
      elsif next_token.tokenType == :IDENTIFIER
        return parse_var_assign
      elsif next_token.tokenType == :KEYWORD && next_token.value == "return"
        return parse_return
      elsif next_token.tokenType == :KEYWORD && next_token.value == "for"
        return parse_for
      end

      nil
    end

    def parse_body
      next_token = lookahead()
      if next_token.tokenType == :KEYWORD && next_token.value == "fn"
        raise Exception.new("Cant declare a function inside a function/loop")
      elsif next_token.tokenType == :KEYWORD && next_token.value == "let"
        return parse_var_decl
      elsif next_token.tokenType == :IDENTIFIER
        return parse_var_assign
      elsif next_token.tokenType == :KEYWORD && next_token.value == "return"
        return parse_return
      end

      nil
    end

    private def parse_for
      expect(:KEYWORD, "for")
      variable = expect(:IDENTIFIER).value
      expect(:KEYWORD, "in")
      lookahead_token = lookahead()
      target = parse_array
      expect(:PUNCTUATION, "{")

      body = [] of BenchASTNode

      # Parse the body until the closing }
      while lookahead().value != "}"
        parsed = parse_body()
        body << parsed.as(BenchASTNode) if parsed
      end

      expect(:PUNCTUATION, "}")
      ForLoop.new(variable, target, body)
    end

    private def parse_function
      expect(:KEYWORD, "fn")
      name = expect(:IDENTIFIER).value
      expect(:PUNCTUATION, "(")
      expect(:PUNCTUATION, ")")
      expect(:PUNCTUATION, "{")

      body = [] of BenchASTNode

      # Parse the body until the closing }
      while lookahead().value != "}"
        parsed = parse_body()
        body << parsed.as(BenchASTNode) if parsed
      end

      expect(:PUNCTUATION, "}")

      FunctionDeclaration.new(name, body)
    end

    private def parse_return
      expect(:KEYWORD, "return")
      value = expect(:IDENTIFIER).value
      expect(:PUNCTUATION, ";")
      ReturnStatement.new(value)
    end

    private def parse_function_call(name : String)
      expect(:PUNCTUATION, "(")
      args = [] of Argument
      if lookahead().value != ")"
        args = parse_args
      else
        expect(:PUNCTUATION, ")")
      end
      expect(:PUNCTUATION, ";")

      FunctionCall.new(name, args)
    end

    private def parse_args
      args = [] of Argument
      while lookahead().value != ")"
        token = get_next
        args << Argument.new(token.value, token.tokenType) if token.tokenType != :PUNCTUATION
      end

      # Skip the closing )
      get_next
      args
    end

    # TODO add operators to variable assignment
    private def parse_var_assign
      name = expect(:IDENTIFIER).value
      if lookahead().value == "("
        return parse_function_call(name)
      end
      expect(:OPERATOR, "=")
      value = parse_expression().as(BenchASTValue)
      expect(:PUNCTUATION, ";")
      VariableDeclaration.new(name, value)
    end

    private def parse_var_decl
      expect(:KEYWORD, "let")
      name = expect(:IDENTIFIER).value
      expect(:OPERATOR, "=")
      value = parse_expression().as(BenchASTValue)
      expect(:PUNCTUATION, ";")
      VariableDeclaration.new(name, value)
    end

    private def parse_array
      values = [] of BenchASTValue
      expect(:PUNCTUATION, "[")
      while lookahead().value != "]"
        token = get_next
        if token.tokenType == :NUMBER || token.tokenType == :STRING || token.tokenType == :IDENTIFIER
          values << token.value
        end
      end

      # Skip the closing ]
      get_next

      ArrayLiteral.new(values)
    end

    private def parse_expression
      lookahead_token = lookahead()
      if lookahead_token.tokenType == :NUMBER
        parse_binary
      elsif lookahead_token.tokenType == :STRING
        get_next
        lookahead_token.value
      elsif lookahead_token.tokenType == :IDENTIFIER
        get_next
        lookahead_token.value
      elsif lookahead_token.tokenType == :PUNCTUATION && lookahead_token.value == "["
        parse_array
      end
    end

    private def parse_binary
      next_token = get_next
      binary_op_tokens = [] of Token
      op_stack = [] of String

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

    private def expect(tokenType : Symbol)
      lookahead_token = lookahead()
      if lookahead_token.tokenType == tokenType
        get_next
      else
        raise Exception.new("Expected #{tokenType.to_s}, got #{lookahead_token.value.to_s}")
      end
    end

    private def expect(tokenType : Symbol, tokenValue : String)
      lookahead_token = lookahead()
      if lookahead_token.tokenType == tokenType && lookahead_token.value == tokenValue
        get_next
      else
        raise Exception.new("Expected #{tokenValue}, got #{lookahead_token.value.to_s}")
      end
    end

    private def expect_any(tokenTypes : Array(Symbol))
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

    private def is_operator(char : String)
      begin
        OPERATOR_PRECEDENCE[char]
        true
      rescue
        false
      end
    end
  end
end
