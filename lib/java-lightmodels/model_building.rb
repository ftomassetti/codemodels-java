require 'lightmodels'
require 'java-lightmodels/parser'

module LightModels

module Java

SRC_EXTENSION = 'java'

MODEL_EXTENSION = "#{SRC_EXTENSION}.lm"

MODULE_PRODUCER = Proc.new do |src|
	root = LightModels::Java.parse_file(src)	
	LightModels::Serialization.rgenobject_to_model(root)
end

def self.generate_models_in_dir(src,dest,model_ext=MODEL_EXTENSION,max_nesting=500)
	LightModels::ModelBuilding.generate_models_in_dir(src,dest,SRC_EXTENSION,model_ext,max_nesting) do |src|
		MODULE_PRODUCER.call(src)
	end
end

def self.generate_model_per_file(src,dest,model_ext=MODEL_EXTENSION,max_nesting=500)
	LightModels::ModelBuilding.generate_model_per_file(src,dest) do |src|
		MODULE_PRODUCER.call(src)
	end
end

def self.handle_models_in_dir(src,error_handler=nil,model_handler)
	raise "Unexisting dir given: #{src}" unless File.exist?(src)
	LightModels::ModelBuilding.handle_models_in_dir(src,SRC_EXTENSION,error_handler,model_handler) do |src|
		MODULE_PRODUCER.call(src)
	end
end

end

end