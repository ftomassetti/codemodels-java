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
			'MyBean' => 4,
			'Int'    => 1,
			'String' => 2,
			'notSoGoodFieldName' => 14,
			'get' => 1,
			'set' => 1,
			'toString' => 1,
			'MyBean [notSoGoodFieldName:' => 1,
			']' => 1,
			'hashCode' => 1,
			'Boolean' => 1,
			'equals' => 1,
			'Object' => 1,
			'obj' => 4,
			'true' => 1,
			'false' => 1,
			'this' => 2,
			'other' => 3
		}
		model_node = Java.parse_code(code)
		terms_map = InfoExtraction.terms_map(model_node)
		assert_equal exp_terms,terms_map
	end

end
