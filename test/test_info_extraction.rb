require 'test/unit'
require 'java-lightmodels'
require 'test_helper'

class TestInfoExtraction < Test::Unit::TestCase

	include LightModels
	include LightModels::Java
	include TestHelper

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

	def test_info_extraction_actionbuttonscomumntag
		file_code = %q{
			package com.technoetic.xplanner.tags.displaytag;

			import javax.servlet.jsp.JspException;
			import javax.servlet.jsp.PageContext;

			import org.apache.commons.logging.Log;
			import org.apache.commons.logging.LogFactory;
			import org.displaytag.properties.MediaTypeEnum;
			import org.displaytag.util.TagConstants;

			import com.technoetic.xplanner.tags.WritableTag;


			public class ActionButtonsColumnTag extends org.displaytag.tags.ColumnTag {
			   // TODO: why not use our ColumnTag instead for consistency?
			//public class ActionButtonsColumnTag extends com.technoetic.xplanner.tags.displaytag.ColumnTag 
			   private static Log log = LogFactory.getLog(ActionButtonsColumnTag.class);
			   ActionButtonsTag actionButtonsTag;

			   public void setActionButtonsTag(ActionButtonsTag actionButtonsTag)
			   {
			      this.actionButtonsTag = actionButtonsTag;
			   }

			    public ActionButtonsColumnTag() {
			        setMedia(MediaTypeEnum.HTML.getName());
			        actionButtonsTag = new ActionButtonsTag();
			        actionButtonsTag.showOnlyActionWithIcon();
			    }

			   public void setPageContext(PageContext context)
			   {
			      super.setPageContext(context);
			      actionButtonsTag.setPageContext(context);
			   }

			    public void setId(String s)
			    {
			        this.id = s;
			        actionButtonsTag.setId(s);
			    }

			   public String getName() {
			        return actionButtonsTag.getName();
			    }

			    public void setName(String name) {
			       actionButtonsTag.setName(name);
			    }

			    public String getScope() {
			        return actionButtonsTag.getScope();
			    }

			    public void setScope(String scope) {
			       actionButtonsTag.setScope(scope);
			    }

			    public int doStartTag() throws JspException {
			        try {
			            WritableTag parentTable = (WritableTag) this.getParent();
			            if (!parentTable.isWritable()) {
			                return SKIP_BODY;
			            }
			            if (!getAttributeMap().containsKey(TagConstants.ATTRIBUTE_NOWRAP))
			                getAttributeMap().put(TagConstants.ATTRIBUTE_NOWRAP, "true");

			            int status = super.doStartTag();
			            if (status != SKIP_BODY) {
			               return actionButtonsTag.doStartTag();
			            }
			            return status;
			        } catch (Exception e) {
			            throw new JspException(e);
			        }
			    }


			   public int doAfterBody() throws JspException {
			       return actionButtonsTag.doAfterBody();
			    }

			    public int doEndTag() throws JspException {
			        actionButtonsTag.doEndTag();
			        try {
			            WritableTag parentTable = (WritableTag) this.getParent();
			            if (!parentTable.isWritable()) {
			                return SKIP_BODY;
			            } else {
			                return super.doEndTag();
			            }
			        } catch (Exception e) {
			            throw new JspException(e);
			        }
			    }

			    public void release() {
			      actionButtonsTag.release();
			    }
			}
		}
		model_node = Java.parse_code(file_code)
		assert_class ClassOrInterfaceDeclaration, model_node.types[0]
		assert_equal 14, model_node.types[0].members.count

		m = model_node.types[0].members[2]
		assert_equal 'setActionButtonsTag', m.name
		assert_map_equal({'actionbuttonstag'=>5, 'set'=>1}, InfoExtraction.terms_map(m))

		m = model_node.types[0].members[3]
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
			'withicon' => 1}, InfoExtraction.terms_map(m))

		raise "Check ALL the other methods and break this tests in separate tests"
	end

end
