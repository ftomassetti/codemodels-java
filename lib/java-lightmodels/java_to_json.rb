require 'emf_jruby'
require 'lightmodels'

module LightModels

module Java

java_import 'japa.parser.JavaParser'
java_import 'java.io.FileInputStream'
java_import 'java.io.ByteArrayInputStream'

def self.parse_file(path)
	fis = FileInputStream.new path
	root = JavaParser.parse(fis)
	fis.close
	convert_to_rgen(root)
end

def self.parse_code(code)
	sis = ByteArrayInputStream.new(code.to_java_bytes)
	root = JavaParser.parse(sis)
	sis.close
	convert_to_rgen(root)
end

private

def self.convert_to_rgen(node)
	raise "It shoudl instantiate the corresponding class!!!!"
end

end

end