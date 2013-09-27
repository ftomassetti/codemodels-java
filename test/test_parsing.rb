require "test_helper"
 
class TestParsing < Test::Unit::TestCase

  include TestHelper
  include LightModels::Java

  class << self
    #include JavaModel
  end

  def setup
    @dir = File.dirname(__FILE__)
  	@example_basic = LightModels.parse_file(@dir+'/example_basic.java')
    @example_accessors = LightModels.parse_file(@dir+'/example_accessors.java')
    @reorder_stories_form = LightModels.parse_file(@dir+'/ReorderStoriesForm.java')
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
    fields = c.all_children_deep_of_type(FieldDeclaration)
    assert_equal 2,fields.count
    assert_not_nil fields.find { |f| f.variables[0].id.name == 'myField'}
    assert_not_nil fields.find { |f| f.variables[0].id.name == 'aFlag'}
  end

  def test_methods_are_found
    c = @example_accessors.only_child_deep_of_type(@metaclass_class)
    methods = c.all_children_deep_of_type(MethodDeclaration)
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

  def test_package
    assert_not_nil @reorder_stories_form.package

    # package is com.technoetic.xplanner.forms
    assert_class PackageDeclaration, @reorder_stories_form.package
    curr_part = @reorder_stories_form.package.name
    ['forms','xplanner','technoetic'].each do |name|
      assert_class QualifiedNameExpr,  curr_part
      assert_equal name, curr_part.name
      curr_part = curr_part.qualifier
    end
    assert_class NameExpr,  curr_part
    assert_equal 'com', curr_part.name
  end

  # TODO check also comments

  def assert_name_expr(exp,name_expr)
    parts = (exp.split '.').reverse
    first_parts = parts[0...-1]

    curr_part = name_expr
    parts[0...-1].each do |name|
      assert_class QualifiedNameExpr,  curr_part
      assert_equal name, curr_part.name, "qualified name expected to have #{name} here"
      curr_part = curr_part.qualifier
    end
    assert_class NameExpr, curr_part
    assert_equal parts.last, curr_part.name
  end

  def assert_import_decl(exp,id)
    assert_class ImportDeclaration, id
    assert_name_expr exp, id.name
  end

  def test_imports
    assert_equal 6,@reorder_stories_form.imports.count

    assert_import_decl 'java.util.ArrayList', @reorder_stories_form.imports[0]
    assert_import_decl 'java.util.Iterator', @reorder_stories_form.imports[1]
    assert_import_decl 'java.util.List', @reorder_stories_form.imports[2]
    assert_import_decl 'javax.servlet.http.HttpServletRequest', @reorder_stories_form.imports[3]
    assert_import_decl 'org.apache.struts.action.ActionErrors', @reorder_stories_form.imports[4]
    assert_import_decl 'org.apache.struts.action.ActionMapping', @reorder_stories_form.imports[5]
  end

  def test_class_name_and_extends
    assert_equal 1,@reorder_stories_form.types.count

    c = @reorder_stories_form.types[0]
    assert_class ClassOrInterfaceDeclaration, c
    assert_equal 'ReorderStoriesForm',c.name
    assert_equal 0, c.implements.count
    assert_equal 1, c.extends.count
    assert_class ClassOrInterfaceType, c.extends[0]
    assert_equal 'AbstractEditorForm', c.extends[0].name
  end

  def test_parse_equals_method
    code = %q{
      class A {
        public boolean equals(Object obj){
          if(this == obj) return true;
          if((obj == null) || !(obj instanceof MyBean)) return false;   
          MyBean other = (MyBean)obj;
          if (this.notSoGoodFieldName==null && !(other.notSoGoodFieldName==null)) return false;
          return this.notSoGoodFieldName.equals(other.notSoGoodFieldName);
        }
      }
    }
    model = LightModels::Java.parse_code(code)
    m = model.types[0].members[0]
    assert_class ClassMethodDeclaration,m
    assert_class BlockStmt,m.body
    
    assert_class IfStmt,m.body.stmts[0]
    assert_class ReturnStmt,m.body.stmts[0].thenStmt
    assert_class BooleanLiteralExpr,m.body.stmts[0].thenStmt.expr
    assert_equal true,m.body.stmts[0].thenStmt.expr.value

    assert_class IfStmt,m.body.stmts[1]
    assert_class ReturnStmt,m.body.stmts[1].thenStmt
    assert_class BooleanLiteralExpr,m.body.stmts[1].thenStmt.expr
    assert_equal false,m.body.stmts[1].thenStmt.expr.value

    assert_class IfStmt,m.body.stmts[3]
    assert_class ReturnStmt,m.body.stmts[3].thenStmt
    assert_class BooleanLiteralExpr,m.body.stmts[3].thenStmt.expr
    assert_equal false,m.body.stmts[3].thenStmt.expr.value
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