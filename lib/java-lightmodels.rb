curr_dir = File.dirname(__FILE__)
Dir[curr_dir+"/jars/*.jar"].each do |jar|
	require jar
end

require 'java-lightmodels/metamodel'
require 'java-lightmodels/java_to_json'
require 'java-lightmodels/model_building'
require 'java-lightmodels/info_extraction'