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

	def assert_method_code_map_to(code,exp)
		r = Java.parse_code("class A { #{code} }")
		ser = LightModels::Serialization.jsonize_obj(r.types[0].members[0])
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

	def test_random_method_1
		code = %q{
			private void gotoTestProject() {
			    if (!tester.isTextPresent(tester.getMessage("project.prefix") + " " + testProjectName)) {
			        if (!tester.isLinkPresentWithText(testProjectName)) {
			            tester.gotoProjectsPage();
			        }
			        tester.clickLinkWithText(testProjectName);
			    }
			    clickLinkWithKeyIfPresent("navigation.project");
			}
		}
		assert_method_code_map_to(code,{
			'gotoTestProject' => 1,
			'tester' => 5,
			'isTextPresent' => 1,
			'getMessage' => 1,
			'project.prefix' => 1,
			' ' => 1,
			'testProjectName' => 3,
			'isLinkPresentWithText' => 1,
			'gotoProjectsPage' => 1,
			'clickLinkWithText' => 1,
			'clickLinkWithKeyIfPresent' => 1,
			'navigation.project' => 1 })
	end

	def test_random_method_2
		code = %q{
			@Override
			protected void initModuleMessageResources(ModuleConfig config) throws ServletException {
			    MessageResources messageResource = (MessageResources) WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext()).getBean("strutsMessageSource");
			    getServletContext().setAttribute(Globals.MESSAGES_KEY, messageResource);
			}
		}
		assert_method_code_map_to(code,{
			'initModuleMessageResources' => 1,
			'ModuleConfig' => 1,
			'config' => 1,
			'ServletException' => 1,
			'MessageResources' => 2,
			'messageResource' => 2,
			'WebApplicationContextUtils' => 1,
			'getRequiredWebApplicationContext' => 1,
			'getServletContext' => 2,
			'getBean' => 1,
			'setAttribute' => 1,
			'Globals' => 1,
			'MESSAGES_KEY' => 1 })
	end 

	def test_random_method_3
		code = %q{
				/**
			     * Getter for the <code>PROPERTY_STRING_PAGING_FOUND_SOMEITEMS</code> property.
			     * @return String
			     */
			public String getPagingFoundSomeItems() {
			    return getProperty(PROPERTY_STRING_PAGING_FOUND_SOMEITEMS);
			}
		}
		assert_method_code_map_to(code,{
			'String' => 1,
			'getPagingFoundSomeItems' => 1,
			'getProperty' => 1,
			'PROPERTY_STRING_PAGING_FOUND_SOMEITEMS' => 1 })

	end

	def test_random_method_4
		code = %q{
			private void setUpQuery(List results) {
			    MockQuery query = new MockQuery();
			    support.hibernateSession.getNamedQueryReturn = query;
			    query.listReturn = results;
			}
		}
		assert_method_code_map_to(code,{
			'setUpQuery' => 1,
			'List' => 1,
			'results' => 2,
			'MockQuery' => 2,
			'query' => 3,
			'support' => 1,
			'hibernateSession' => 1,
			'getNamedQueryReturn' => 1,
			'listReturn' => 1 })
	end
	
	def test_random_method_5
		code = %q{
			public Project newProject() throws HibernateException {
			    Project project = new Project();
			    project.setName("Test project");
			    session.save(project);
			    project.setName("Test project " + project.getId());
			    return project;
			}
		}		
		assert_method_code_map_to(code,{
			'Project' => 3,
			'newProject' => 1,
			'HibernateException' => 1,
			'project' => 6,
			'setName' => 2,
			'Test project' => 1,
			'Test project ' => 1,
			'session' => 1,
			'save' => 1,
			'getId' => 1 })
	end
	
	def test_random_method_6
		code = %q{
			void assertFormElementEquals(String formElementName, String expectedValue);
		}
		assert_method_code_map_to(code,{
			'assertFormElementEquals' => 1,
			'String' => 2,
			'formElementName' => 1,
			'expectedValue' => 1 })
	end

	def test_random_method_7
		code = %q{
			@Override
			public LobHelper getLobHelper() {
			    return null;
			}
		}
		assert_method_code_map_to(code,{
			'LobHelper' => 1,
			'getLobHelper' => 1 })
	end
	
	def test_random_method_8
		code = %q{
			private int getFontSize() {
			    return (int) Math.round(getHeight() * 0.91);
			}
		}
		assert_method_code_map_to(code,{
			'getFontSize' => 1,
			'Math' => 1,
			'round' => 1,
			'getHeight' => 1,
			'0.91' => 1 })
	end
	
	def test_random_method_9
		code = %q{
			public Collection getCurrentCompletedTasksForPerson(int personId);
		}
		assert_method_code_map_to(code,{
			'Collection' => 1,
			'getCurrentCompletedTasksForPerson' => 1,
			'personId' => 1 })		
	end
	
	def test_random_method_10
		code = %q{
			public Hashtable getTaskEstimatedHoursByDisposition() {
			    if (taskDispositionEstimatedHours == null) {
			        taskDispositionEstimatedHours = new DispositionAggregator(true) {

			            @Override
			            protected double getValue(Task task) {
			                return task.getEstimatedHours();
			            }
			        }.aggregateByGroup();
			    }
			    return taskDispositionEstimatedHours;
			}
		}
		assert_method_code_map_to(code,{
			'Hashtable' => 1,
			'getTaskEstimatedHoursByDisposition' => 1,
			'taskDispositionEstimatedHours' => 3,
			'DispositionAggregator' => 1,
			'getValue' => 1,
			'Task' => 1,
			'task' => 2,
			'getEstimatedHours' => 1,
			'aggregateByGroup' => 1 })
	end

end
