require 'emf_jruby'
require 'json'
require 'java_to_json'

$PWD = File.dirname(__FILE__)

raise "Usage: java_models_builder <sources> <models>" unless ARGV.count==2

sources_path = ARGV[0]
models_path = ARGV[1]
raise "Path to sources does not exist or it is not a dir: #{sources_path}" unless File.exist?(sources_path) and File.directory?(sources_path)
raise "Path to models does not exist or it is not a dir: #{models_path}" unless File.exist?(models_path) and File.directory?(models_path)

EObject = org.eclipse.emf.ecore.EObject
JavaResource = org.emftext.language.java.resource.java.mopp.JavaResource
JavaResourceUtil = org.emftext.language.java.resource.java.util.JavaResourceUtil
EcoreUtil = org.eclipse.emf.ecore.util.EcoreUtil

$SRC  = sources_path
$DEST = models_path
$VERBOSE = false

$resource_set = create_resource_set()

LightModels.generate_models_in_dir($SRC,$DEST,'java','json') do |src|
	java_resource = get_resource($resource_set, src)
	raise "wrong number of roots" unless java_resource.contents.size == 1
	root = java_resource.contents.get(0)
	LightModels.eobject_to_model(root)
end
