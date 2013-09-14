require 'java-lightmodels'
require 'json'

require "test/unit"
require "test_helper"
 
class TestCorrespondences < Test::Unit::TestCase

  include TestHelper
  include LightModels
  include LightModels::Java

  class << self
   # include JavaModel
  end

  def setup
    
  end

  def test_correspondance_of_field
    code = "class A extends B { int fieldB; int getB(){ return fieldB; } }"
    nt = Java.node_tree_from_code(code)
    mt = Java.parse_code(code)
    model_field = mt.types[0].members[0]
    node_field  = nt.types[0].members[0]
    assert_equal node_field, Java.corresponding_node(model_field,nt)
    assert_equal "int fieldB;", Java.corresponding_node(model_field,nt).to_s 
  end

  def test_corresponding_node_from_code
    code = "class A extends B { int fieldB; int getB(){ return fieldB; } }"
    nt = Java.node_tree_from_code(code)
    mt = Java.parse_code(code)
    model_field = mt.types[0].members[0]
    node_field  = nt.types[0].members[0]
    assert_equal node_field, Java.corresponding_node_from_code(model_field,code)
    assert_equal "int fieldB;", Java.corresponding_node_from_code(model_field,code).to_s
  end

end