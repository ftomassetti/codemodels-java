curr_dir = File.dirname(__FILE__)
Dir[curr_dir+"/jars/*.jar"].each do |jar|
	require jar
end

require 'java-lightmodels/metamodel'
require 'java-lightmodels/parser'
require 'java-lightmodels/model_building'
require 'java-lightmodels/info_extraction'
require 'java-lightmodels/language'