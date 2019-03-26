alias BenchASTValue = Bool | Int64 | Float64 | String | BinaryExpression | ArrayLiteral

OPERATOR_PRECEDENCE = {
  "="  => 1,
  "||" => 2,
  "&&" => 3,
  "<"  => 7,
  ">"  => 7,
  "<=" => 7,
  ">=" => 7,
  "==" => 7,
  "!=" => 7,
  "+"  => 10,
  "-"  => 10,
  "*"  => 20,
  "/"  => 20,
  "%"  => 20,
}

# TODO: add to_lua as an abstract method here
abstract class BenchASTNode
  def to_lua
  end
end

class VariableDeclaration < BenchASTNode
  def initialize(@name : String, @value : BenchASTValue)
  end

  def to_lua
    if @value.is_a?(String)
      lua_string = "local #{@name} = \"#{@value}\""
    elsif @value.is_a?(BinaryExpression)
      lua_string = "local #{@name} = #{@value.as(BinaryExpression).to_lua}"
    elsif @value.is_a?(ArrayLiteral)
      lua_string = "local #{@name} = #{@value.as(ArrayLiteral).to_lua}"
    else
      lua_string = "local #{@name} = #{@value}"
    end
  end
end

class VariableAssignment < BenchASTNode
  def initialize(@name : String, @value : BenchASTValue)
  end

  def to_lua
    if @value.is_a?(String)
      lua_string = "#{@name} = \"#{@value}\""
    elsif @value.is_a?(BinaryExpression)
      lua_string = "local #{@name} = #{@value.as(BinaryExpression).to_lua}"
    elsif @value.is_a?(ArrayLiteral)
      lua_string = "local #{@name} = #{@value.as(ArrayLiteral).to_lua}"
    else
      lua_string = "#{@name} = #{@value}"
    end
  end
end

class FunctionDeclaration < BenchASTNode
  def initialize(@name : String, @body : Array(BenchASTNode))
  end

  def to_lua
    lua_string = "function #{@name}()\n"
    body = [] of String

    @body.each do |node|
      body << node.to_lua.as(String)
    end

    lua_string += body.join("\n")
    lua_string = lua_string + "\nend"
    lua_string
  end
end

class ReturnStatement < BenchASTNode
  def initialize(@value : String)
  end

  def to_lua
    "return #{@value}"
  end
end

class BinaryExpression < BenchASTNode
  def initialize(@postfix : String, @raw : String)
  end

  def to_lua
    @raw
  end
end

class ArrayLiteral < BenchASTNode
  def initialize(@values : Array(BenchASTValue))
  end

  # TODO: handle strings in values (no quotes around them for now)
  def to_lua
    "{#{@values.join(",")}}"
  end
end

class FunctionCall < BenchASTNode
  def initialize(@name : String, @args : Array(Argument))
  end

  def to_lua
    processed_args = @args.map { |args| arg.to_lua }
    "#{@name}(#{processed_args.join(", ")})"
  end
end

class Argument < BenchASTNode
  def initialize(@value : String, @type : Symbol)
  end

  def to_lua
    @value
  end
end

class ForLoop < BenchASTNode
  def initialize(@variable : String, @target : ArrayLiteral, @body : Array(BenchASTNode))
  end
end

class TopLevel
  def initialize
    @name = "program"
    @program = Array(BenchASTNode).new
  end

  def push(node : BenchASTNode)
    @program << node
  end

  def get_program
    @program
  end
end
