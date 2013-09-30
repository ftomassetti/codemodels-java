require 'codemodels'
require 'codemodels/java/parser'

module CodeModels

module Java

SRC_EXTENSION = 'java'

MODEL_EXTENSION = "#{SRC_EXTENSION}.lm"

MODEL_PRODUCER = Proc.new do |src|
	root = CodeModels::Java.parse_file(src)	
end

SERIALIZED_MODEL_PRODUCER = Proc.new do |src|
	root = CodeModels::Java.parse_file(src)	
	CodeModels::Serialization.rgenobject_to_model(root)
end

def self.generate_models_in_dir(src,dest,model_ext=MODEL_EXTENSION,max_nesting=500)
	CodeModels::ModelBuilding.generate_models_in_dir(src,dest,SRC_EXTENSION,model_ext,max_nesting) do |src|
		SERIALIZED_MODEL_PRODUCER.call(src)
	end
end

def self.generate_model_per_file(src,dest,model_ext=MODEL_EXTENSION,max_nesting=500)
	CodeModels::ModelBuilding.generate_model_per_file(src,dest) do |src|
		SERIALIZED_MODEL_PRODUCER.call(src)
	end
end

def self.handle_models_in_dir(src,error_handler=nil,model_handler)
	raise "Unexisting dir given: #{src}" unless File.exist?(src)
	CodeModels::ModelBuilding.handle_models_in_dir(src,SRC_EXTENSION,error_handler,model_handler) do |src|
		MODEL_PRODUCER.call(src)
	end
end

end

end