require "./codegen"

class Crystal::CodeGenVisitor
  def codegen_add_reference
  end

  def codegen_dereference(var)
    call = Call.new(var, "dereference", [] of ASTNode)
    call.target_defs = 
  end
end
