require "./codegen"

class Crystal::CodeGenVisitor
  def codegen_dereference(node, var)
    STDERR.puts "codegen_dereference\nnode:\n#{node}\nvar:\n#{var}"
    call = Call.new(var, "dereference", [] of ASTNode).at(node)
    @program.visit_main call
  end

  def codegen_add_reference(node, var)
    STDERR.puts "codegen_add_reference\nnode:\n#{node}\nvar:\n#{var}"
    call = Call.new(var, "add_reference", [] of ASTNode).at(node)
    @program.visit_main call
  end
end
