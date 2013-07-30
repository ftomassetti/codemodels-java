require 'java_model_jrb'
require 'emf_jruby'
require 'json'

require "test/unit"
 
class TestJavaToJson < Test::Unit::TestCase

  def setup
    @dir = File.dirname(__FILE__)
  	@rs = create_resource_set()
  	@example_basic = get_resource(@rs,@dir+'/example_basic.java')
    @example_accessors = get_resource(@rs,@dir+'/example_accessors.java')
  	@eclass_class = org.emftext.language.java.classifiers.ClassifiersPackage.eINSTANCE.getClass_
  end

  def test_model_contains_class
    assert_not_nil EObjectUtil.only_content_of_eclass(@example_basic,@eclass_class)
  end

  def test_myclass_has_right_name    
    my_class = EObjectUtil.only_content_of_eclass(@example_basic,@eclass_class)
    assert_equal 'MyClass', my_class.name
  end

  def test_myclass_has_right_fullname    
    my_class = EObjectUtil.only_content_of_eclass(@example_basic,@eclass_class)
    assert_equal('it.polito.MyClass',eobject_class_qname(my_class))
  end

  def test_eobject_contains_fullname
    $nextId = 1
    my_class = EObjectUtil.only_content_of_eclass(@example_basic,@eclass_class)
    js = jsonize_java_obj(my_class)
    assert js.has_key? 'attr_fullname'
    assert_equal('it.polito.MyClass',js['attr_fullname'])
  end

  def test_fields_are_found
    $nextId = 1
    js = jsonize_java_obj(EObjectUtil.only_content_of_eclass(@example_accessors,@eclass_class))
    jfields = get_deep_content_of_type(js,'http://www.emftext.org/java/members#Field')
    assert_equal(2,jfields.count)
    assert_not_nil jfields.find { |m| m['attr_name'] == 'myField'}
    assert_not_nil jfields.find { |m| m['attr_name'] == 'aFlag'}
  end

  def test_methods_are_found
    $nextId = 1
    my_class = EObjectUtil.only_content_of_eclass(@example_accessors,@eclass_class)
    js = jsonize_java_obj(my_class)
    jmethods = get_deep_content_of_type(js,'http://www.emftext.org/java/members#ClassMethod')
    assert_equal(4,jmethods.count)
    assert_not_nil jmethods.find { |m| m['attr_name'] == 'getMyField'}
    assert_not_nil jmethods.find { |m| m['attr_name'] == 'setMyField'}
    assert_not_nil jmethods.find { |m| m['attr_name'] == 'isAFlag'}
    assert_not_nil jmethods.find { |m| m['attr_name'] == 'setAFlag'}
  end

  def get_field(js,field_name)
    get_specific_deep_content(js,'http://www.emftext.org/java/members#Field') do |f|
      f['attr_name'] == field_name
    end
  end

  def get_method(js,method_name)
    get_specific_deep_content(js,'http://www.emftext.org/java/members#ClassMethod') do |m|
      m['attr_name'] == method_name
    end
  end

  def test_getter_not_boolean_is_marked
    $nextId = 1
    js = jsonize_java_obj(EObjectUtil.only_content_of_eclass(@example_accessors,@eclass_class))

    field = get_field js, 'myField'
    getter = get_method js, 'getMyField'

    # field must have relation to getter 'getter'
    assert_equal(getter['id'], field['relnoncont_getter'])

    # getter must have relation to field 'forField'
    assert_equal(true, getter['attr_getter'])
    assert_equal(field['id'], getter['relnoncont_getterFor'])
  end
 
end