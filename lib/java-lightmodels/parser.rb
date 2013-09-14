require 'emf_jruby'
require 'lightmodels'

module LightModels

module Java

class << self
	include ParserWrapper
end

java_import 'japa.parser.JavaParser'
java_import 'java.io.FileInputStream'
java_import 'java.io.ByteArrayInputStream'

def self.parse_file(path)
	fis = FileInputStream.new path
	root = JavaParser.parse(fis)
	fis.close
	node_to_model(root)
end

def self.parse_code(code)
	sis = ByteArrayInputStream.new(code.to_java_bytes)
	root = JavaParser.parse(sis)
	sis.close
	node_to_model(root)
end

private

def self.adapter_specific_class(model_class,ref)
	return nil unless LightModels::Java::PROP_ADAPTERS[model_class]
	LightModels::Java::PROP_ADAPTERS[model_class][ref.name]
end

# def self.convert_to_rgen(node)
# 	metaclass = get_corresponding_metaclass(node.class)
# 	instance = metaclass.new
# 	metaclass.ecore.eAllAttributes.each do |attr|
# 		puts " * populate #{attr}"
# 	end
# 	metaclass.ecore.eAllReferences.each do |ref|
# 		puts " * populate #{ref}"
# 	end
# 	instance
# end

end

end