curr_dir = File.dirname(__FILE__)
Dir[curr_dir+"/../jars/*.jar"].each do |jar|
	require jar
end

require 'codemodels/java/metamodel'
require 'codemodels/java/parser'
require 'codemodels/java/model_building'
require 'codemodels/java/info_extraction'
require 'codemodels/java/language'