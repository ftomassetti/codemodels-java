require "test_helper"
 
class TestCorrespondences < Test::Unit::TestCase

  include TestHelper
  include CodeModels
  include CodeModels::Java

  J = CodeModels::Java

  # def test_correspondance_of_field
  #   code = "class A extends B { int fieldB; int getB(){ return fieldB; } }"
  #   nt = CodeModels.parse_string(code,:Java)
  #   node_field  = nt.types[0].members[0]
  #   assert_equal "int fieldB;", node_field.to_s 
  # end

  # def test_corresponding_node_from_code
  #   code = "class A extends B { int fieldB; int getB(){ return fieldB; } }"
  #   nt = CodeModels.parse_string(code,:Java)
  #   node_field  = nt.types[0].members[0]
  #   assert_equal node_field, J::DefaultParser.corresponding_node_from_code(model_field,code)
  #   assert_equal "int fieldB;", J::DefaultParser.corresponding_node_from_code(model_field,code).to_s
  # end

end