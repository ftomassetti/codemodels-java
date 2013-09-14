require 'java-lightmodels'
require 'json'

require "test/unit"
 
class TestJavaToJson < Test::Unit::TestCase

  include LightModels::Java

  class << self
    include JavaModel
  end

  def setup
    @dir = File.dirname(__FILE__)
  	@example_basic = LightModels::Java.parse_file(@dir+'/example_basic.java')
    @example_accessors = LightModels::Java.parse_file(@dir+'/example_accessors.java')
    @metaclass_class = LightModels::Java::ClassOrInterfaceDeclaration
  end

  def test_model_contains_class
    assert_not_nil @example_basic.only_child_deep_of_type(@metaclass_class)
  end

  def test_myclass_has_right_name    
    my_class = @example_basic.only_child_deep_of_type(@metaclass_class)
    assert_equal 'MyClass', my_class.name
  end

  # def test_myclass_has_right_fullname    
  #   my_class = @example_basic.only_child_deep_of_type(@metaclass_class)
  #   assert_equal('it.polito.MyClass',JavaModel.eobject_class_qname(my_class))
  # end

  # def test_eobject_contains_fullname
  #   my_class = @example_basic.only_child_deep_of_type(@metaclass_class)
  #   puts "my_class #{my_class.class}"
  #   js = LightModels::Serialization.jsonize_obj(my_class)
  #   assert js.has_key? 'attr_fullname'
  #   assert_equal('it.polito.MyClass',js['attr_fullname'])
  # end

  def test_fields_are_found
    c = @example_accessors.only_child_deep_of_type(@metaclass_class)
    fields = c.children_deep_of_type(FieldDeclaration)
    assert_equal 2,fields.count
    assert_not_nil fields.find { |f| f.variables[0].id.name == 'myField'}
    assert_not_nil fields.find { |f| f.variables[0].id.name == 'aFlag'}
  end

  def test_methods_are_found
    c = @example_accessors.only_child_deep_of_type(@metaclass_class)
    methods = c.children_deep_of_type(MethodDeclaration)
    assert_equal(4,methods.count)
    assert_not_nil methods.find { |m| m.name == 'getMyField'}
    assert_not_nil methods.find { |m| m.name == 'setMyField'}
    assert_not_nil methods.find { |m| m.name == 'isAFlag'}
    assert_not_nil methods.find { |m| m.name == 'setAFlag'}
  end

  def get_field(c,field_name)
    c.children_deep_of_type(FieldDeclaration).select { |f| f.variables[0].id.name == field_name }    
  end

  def get_method(c,method_name)
    c.children_deep_of_type(MethodDeclaration).select { |m| m.name == method_name }    
  end

  # def test_getter_not_boolean_is_marked
  #   c = @example_accessors.only_child_deep_of_type(@metaclass_class)

  #   field = get_field c, 'myField'
  #   getter = get_method c, 'getMyField'

  #   # field must have relation to getter 'getter'
  #   assert_equal (getter['id'], field['relnoncont_getter'])

  #   # getter must have relation to field 'forField'
  #   assert_equal (true, getter['attr_getter'])
  #   assert_equal (field['id'], getter['relnoncont_getterFor'])
  # end
 
end