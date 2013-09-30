require 'json'
require 'codemodels/java/model_building'
require 'codemodels'

$PWD = File.dirname(__FILE__)

raise "Usage: java_models_builder <sources> <models>" unless ARGV.count==2

sources_path = ARGV[0]
models_path = ARGV[1]
raise "Path to sources does not exist or it is not a dir: #{sources_path}" unless File.exist?(sources_path) and File.directory?(sources_path)
raise "Path to models does not exist or it is not a dir: #{models_path}" unless File.exist?(models_path) and File.directory?(models_path)

$SRC  = sources_path
$DEST = models_path

CodeModels::Java.generate_java_models_in_dir($SRC,$DEST)