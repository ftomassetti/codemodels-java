require 'lightmodels'
require 'java-lightmodels/java_to_json'

module JavaModel

@resource_set = JavaModel.create_resource_set()

SRC_EXTENSION = 'java'

MODEL_EXTENSION = "#{SRC_EXTENSION}.lm"

MODULE_PRODUCER = Proc.new do |src|
	java_resource = JavaModel.get_resource(@resource_set, src)
	raise "wrong number of roots" unless java_resource.contents.size == 1
	root = java_resource.contents.get(0)
	LightModels::Serialization.eobject_to_model(root,JavaModel::ADAPTERS_MAP)
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