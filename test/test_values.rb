# Here we test that models of Java code contains all the information
# that they should

require 'test/unit'
require 'java-lightmodels'

include JavaModel

class TestValues < Test::Unit::TestCase

	include LightModels

	def assert_map(exp,map)
		# ignore boolean values...
		#map.delete true
		#map.delete false

		#assert_equal exp.count,map.count, "Expected to have keys: #{exp.keys}, it has #{map.keys}"
		exp.each do |k,v|
			assert_equal exp[k],map[k], "Expected #{k} to have #{exp[k]} instances, it has #{map[k]}. Keys of the map: #{map.keys}"
		end
	end

	def assert_code_map_to(code,exp)
		r = Java.parse_code(code)
		ser = LightModels::Serialization.jsonize_obj(r)
		map = LightModels::Query.collect_values_with_count(ser)
		assert_map(exp,map)
	end

	def test_local_variables
		code = %q{
			class MyClass {
				void m(){
					int a, b;
					String qwerty;
				}
			}
		}
		assert_code_map_to(code, {'MyClass'=> 1, 'm' => 1, 'a' => 1, 'b' => 1, 'qwerty' => 1, 'String' => 1})
	end

end
