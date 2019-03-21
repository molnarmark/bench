alias TokenValue = Bool | Int64 | Float64 | String | BinaryExpression

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
  def initialize(@name : String, @value : TokenValue)
  end
end

class FormDeclaration < BenchASTNode
  def initialize(@name : String, @body : Array(BenchASTNode))
  end
end

class RetStatement < BenchASTNode
  def initialize(@value : String)
  end
end

class BinaryExpression < BenchASTNode
  def initialize(@infix : String)
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
