require 'test/unit'
require 'java-lightmodels'

class TestInfoExtraction < Test::Unit::TestCase

	include LightModels
	include LightModels::Java

	def test_camel_to_words_single_word_upcase
		assert_equal ['CIAO'],InfoExtraction.camel_to_words('CIAO')
	end

	def test_camel_to_words_single_word_downcase
		assert_equal ['ciao'],InfoExtraction.camel_to_words('ciao')
	end

	def test_camel_to_words_proper_starting_down
		assert_equal ['ciao','Bello'],InfoExtraction.camel_to_words('ciaoBello')
	end

	def test_camel_to_words_proper_starting_up
		assert_equal ['Ciao','Bello'],InfoExtraction.camel_to_words('CiaoBello')
	end

	def test_camel_to_words_with_numbers
		assert_equal ['test','1'],InfoExtraction.camel_to_words('test1')
	end

	def test_camel_to_words_upcase_numbers
		assert_equal ['TEST','1'],InfoExtraction.camel_to_words('TEST1')
	end

	def test_camel_to_words_with_uppercase_word
		assert_equal ['Ciao','BELLO','Come','Va'],InfoExtraction.camel_to_words('CiaoBELLOComeVa')
	end

	def test_camel_to_words_empty
		assert_equal [''],InfoExtraction.camel_to_words('')
	end

	def assert_map_equal(exp,act,model=nil)
		fail "Unexpected keys #{act.keys-exp.keys}. Actual map: #{act}" if (act.keys-exp.keys).count > 0
		fail "Missing keys #{exp.keys-act.keys}. Actual map: #{act}" if (exp.keys-act.keys).count > 0
		exp.each do |k,exp_v|
			fail "For #{k} expected #{exp_v}, found #{act[k]}, model=#{model}" if act[k]!=exp_v
		end
	end

	def test_proper_terms_extraction_on_bean
		code = %q{
			class MyBean {
				private String notSoGoodFieldName;
				
				public String getNotSoGoodFieldName(){ return notSoGoodFieldName; }
				
				public void setNotSoGoodFieldName(String notSoGoodFieldName){ this.notSoGoodFieldName = notSoGoodFieldName; }
				
				public String toString(){
					return "MyBean [notSoGoodFieldName: "+notSoGoodFieldName+"]";
				}
				
				public int hashCode(){
					return notSoGoodFieldName.hashCode();
				}
				
				public boolean equals(Object obj){
					if(this == obj) return true;
					if((obj == null) || !(obj instanceof MyBean)) return false;		
					MyBean other = (MyBean)obj;
					if (this.notSoGoodFieldName==null && !(other.notSoGoodFieldName==null)) return false;
					return this.notSoGoodFieldName.equals(other.notSoGoodFieldName);
				}
			}
		}
		exp_terms = {
			'mybean' => 4,
			'int'    => 1,
			'string' => 5,
			'notsogoodfieldname' => 13,
			'get' => 1,
			'set' => 1,
			'MyBean [notSoGoodFieldName:' => 1,
			']' => 1,
			'hashcode' => 2,
			'to' => 1,
			'boolean' => 1,
			'equals' => 2,
			'object' => 1,
			'obj' => 5,
			'true' => 1,
			'false' => 2,
			#'this' => 2,
			'other' => 3
		}
		model_node = Java.parse_code(code)
		terms_map = InfoExtraction.terms_map(model_node)
		#puts model_node
		assert_map_equal exp_terms,terms_map,LightModels::Serialization.jsonize_obj(model_node)
	end

end
