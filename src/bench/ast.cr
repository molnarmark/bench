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

abstract class BenchASTNode
end

class VariableDeclaration < BenchASTNode
  def initialize(@name : String, @value : BenchASTValue)
  end
end

class FunctionDeclaration < BenchASTNode
  def initialize(@name : String, @body : Array(BenchASTNode))
  end
end

class ReturnStatement < BenchASTNode
  def initialize(@value : String)
  end
end

class BinaryExpression < BenchASTNode
  def initialize(@infix : String)
  end
end

class ArrayLiteral < BenchASTNode
  def initialize(@values : Array(BenchASTValue))
  end
end

class FunctionCall < BenchASTNode
  def initialize(@name : String, @args : Array(Argument))
  end
end

class Argument < BenchASTNode
  def initialize(@value : String, @type : Symbol)
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
end
