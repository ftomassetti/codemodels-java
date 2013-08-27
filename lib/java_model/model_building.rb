require 'lightmodels'
require 'java_model/java_to_json'

module JavaModel

@resource_set = JavaModel.create_resource_set()

def self.generate_java_models_in_dir(src,dest,model_ext='java.lm')
	LightModels::ModelBuilding.generate_models_in_dir(src,dest,'java',model_ext) do |src|
		java_resource = JavaModel.get_resource(@resource_set, src)
		raise "wrong number of roots" unless java_resource.contents.size == 1
		root = java_resource.contents.get(0)
		LightModels::Serialization.eobject_to_model(root)
	end
end

end