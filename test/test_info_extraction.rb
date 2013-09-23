require 'test_helper'

class TestInfoExtraction < Test::Unit::TestCase

	include LightModels
	include LightModels::Java
	include TestHelper

	def setup
		@actionbuttonscomumntag_model_node = LightModels::Java.parse_code(read_test_data('ActionButtonsColumnTag.java'))
		@csvexporter_model_node            = LightModels::Java.parse_code(read_test_data('CsvExporter.java'))
		@authconstraint_model_node         = LightModels::Java.parse_code(read_test_data('AuthConstraint.java'))
		@testiteration_model_node          = LightModels::Java.parse_code(read_test_data('TestIteration.java'))
	end

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
			'other' => 3
		}
		model_node = LightModels::Java.parse_code(code)
		terms_map = model_node.terms_map
		assert_map_equal exp_terms,terms_map,model_node.to_json
	end

	def test_actionbutonscomumntag_sanity_check
		assert_class ClassOrInterfaceDeclaration, @actionbuttonscomumntag_model_node.types[0]
		assert_equal 14, @actionbuttonscomumntag_model_node.types[0].members.count
	end

	def test_info_extraction_actionbuttonscomumntag_method_1
		m = @actionbuttonscomumntag_model_node.types[0].members[2]
		assert_equal 'setActionButtonsTag', m.name
		assert_map_equal({'actionbuttonstag'=>5, 'set'=>1}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_2
		m = @actionbuttonscomumntag_model_node.types[0].members[3]
		assert_equal 'ActionButtonsColumnTag', m.name
		# media could be breaken, it is border line...	
		# action it is used in separate contexts so sometimes it is broken
		assert_map_equal({'set'=>1, 'media'=>1,
			'mediatypeenum'=>1, 'html'=>1,'get'=>1,'name'=>1,
			'action' => 1,
			'actionbuttons' => 1,
			'column' => 1,
			'tag' => 1,
			'actionbuttonstag'=>3,'showonly'=>1,
			'withicon' => 1}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_3
		m = @actionbuttonscomumntag_model_node.types[0].members[4]
		assert_equal 'setPageContext', m.name
		assert_map_equal({'set'=>3, 'pagecontext'=>4,
			'context'=>3, 'actionbuttonstag'=>1}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_4
		m = @actionbuttonscomumntag_model_node.types[0].members[5]
		assert_equal 'setId', m.name
		assert_map_equal({'set'=>2, 'id'=>3, 'string'=>1,
			's'=>3,'actionbuttonstag'=>1}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_5
		m = @actionbuttonscomumntag_model_node.types[0].members[6]
		assert_equal 'getName', m.name
		assert_map_equal({'get'=>2, 'name'=>2, 'string'=>1,
			'actionbuttonstag'=>1}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_6
		m = @actionbuttonscomumntag_model_node.types[0].members[7]
		assert_equal 'setName', m.name
		assert_map_equal({'set'=>2, 'name'=>4, 'string'=>1,
			'actionbuttonstag'=>1}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_7
		m = @actionbuttonscomumntag_model_node.types[0].members[8]
		assert_equal 'getScope', m.name
		assert_map_equal({'get'=>2, 'scope'=>2, 'string'=>1,
			'actionbuttonstag'=>1}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_8
		m = @actionbuttonscomumntag_model_node.types[0].members[9]
		assert_equal 'setScope', m.name
		assert_map_equal({'set'=>2, 'scope'=>4, 'string'=>1,
			'actionbuttonstag'=>1}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_9
		m = @actionbuttonscomumntag_model_node.types[0].members[10]
		assert_equal 'doStartTag', m.name
		assert_map_equal({'int'=>2, 'do'=>3, 'start'=>3,
			'tag'=>7,
			'actionbuttonstag'=>1, 'jspexception'=>2,
			'writable'=>3, 'parent'=>1,'parenttable'=>2,
			'get'=>3,'is'=>1,'SKIP_BODY'=>2,'constants'=>2,
			'ATTRIBUTE_NOWRAP'=>2,'true'=>1,'attributemap'=>2,
			'containskey'=>1,'put'=>1,
			'status'=>3,'exception'=>1,'e'=>2}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_10
		m = @actionbuttonscomumntag_model_node.types[0].members[11]
		assert_equal 'doAfterBody', m.name
		assert_map_equal({'int'=>1, 'do'=>2, 'afterbody'=>2,
			'actionbuttonstag'=>1, 'jspexception'=>1}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_11
		m = @actionbuttonscomumntag_model_node.types[0].members[12]
		assert_equal 'doEndTag', m.name
		assert_map_equal({'int'=>1, 'do'=>3, 'end'=>3,
			'actionbuttonstag'=>1, 'jspexception'=>2,
			'writable'=>3, 'tag'=>5,'is'=>1,
			'parent'=>1,'parenttable'=>2,
			'SKIP_BODY'=>1,'exception'=>1,'e'=>2, 'get'=>1}, m.terms_map)
	end

	def test_info_extraction_actionbuttonscomumntag_method_12
		m = @actionbuttonscomumntag_model_node.types[0].members[13]
		assert_equal 'release', m.name
		assert_map_equal({'release'=>2,
			'actionbuttonstag'=>1}, m.terms_map)
	end

	def test_info_extraction_csvexporter_1
		m = @csvexporter_model_node.types[0].members[4]
		assert_equal 'getFileExtension', m.name
		# there is only a getter so it does not recognize it as separate
		assert_map_equal({'getfileextension'=>1,'string'=>1,'csv'=>1}, m.terms_map)
	end

	def test_info_extraction_csvexporter_2
		m = @csvexporter_model_node.types[0].members[5]
		assert_equal 'export', m.name
		assert_map_equal({
			'byte'=>1,
			'bytearray'=>1,
			'bytearrayoutputstream'=>2,
			'session'=>2,'object'=>2,
			'data'=>2,'to'=>1,
			'export'=>2,'exception'=>1,
			'override'=>1}, m.terms_map)
	end

	def test_info_extraction_authconstraint_1
		m = @authconstraint_model_node.types[0].members[1]
		assert_equal 'addRoleName', m.name
		assert_map_equal({'add'=>2,'role'=>3,'name'=>3,'string'=>1,'rolenames'=>1}, m.terms_map)
	end	

	def test_info_extraction_authconstraint_2
		m = @authconstraint_model_node.types[0].members[2]
		assert_equal 'getRoleNames', m.name
		assert_map_equal({'collection'=>1,'string'=>1,'get'=>1,'rolenames'=>2}, m.terms_map)
	end

	def test_info_extraction_testiteration_1
		m = @testiteration_model_node.types[0].members[4]
		assert_equal 'testGetRemainingHours', m.name
		assert_map_equal({'test'=>1,'get'=>2,'remaining'=>2,'assertequals'=>1,
			'0.0d'=>1,'iteration'=>1,'task'=>1,'0.0'=>1,'exception'=>1,'hours'=>2}, m.terms_map)
	end	

	def test_info_extraction_testiteration_2
		m = @testiteration_model_node.types[0].members[10]
		assert_equal 'testGetAddedHours', m.name
		assert_map_equal({'test'=>2,'get'=>2,'added'=>2,'hours'=>2,'assertequals'=>1,'iteration'=>4,
			'estimated'=>1,'tasks'=>1,
			'5.0d'=>1,'0.0'=>1,'exception'=>1,'set'=>1,'up'=>1,'of'=>1}, m.terms_map)
	end

end
