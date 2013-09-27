require 'lightmodels'

module LightModels
module Java

class << self
	include ParserWrapper
end

java_import 'japa.parser.JavaParser'
java_import 'java.io.FileInputStream'
java_import 'java.io.ByteArrayInputStream'

def self.containment_pos(node)
	container = node.eContainer
	children  = node.eContainer.send(node.eContainingFeature)
	if children.respond_to?(:each)
		children.each_with_index do |c,i|
			return i if c==node
		end
		raise "Not found"
	else
		raise "Not found" unless children==node
		0
	end
end

# node tree contains the original 
def self.corresponding_node(model_element,node_tree)
	return node_tree unless model_element.eContainer
	corresponding_parent_node = corresponding_node(model_element.eContainer,node_tree)
	containment_pos = containment_pos(model_element)
	containing_feat = model_element.eContainingFeature

	children = corresponding_parent_node.send(containing_feat)
	if children.respond_to?(:each)
		children[containment_pos]
	else
		children
	end
end

def self.node_tree_from_code(code)
	sis = ByteArrayInputStream.new(code.to_java_bytes)
	node_tree = JavaParser.parse(sis)
	sis.close
	node_tree
end

def self.corresponding_node_from_code(model_element,code)
	sis = ByteArrayInputStream.new(code.to_java_bytes)
	node_tree = JavaParser.parse(sis)
	sis.close
	corresponding_node(model_element,node_tree)
end

def self.parse_code(code)	
	node_to_model(node_tree_from_code(code))
end

class Parser < LightModels::Parser

	def parse_code(code)
		LightModels::Java.parse_code(code)
	end

end

DefaultParser = Parser.new

def self.parse_file(path)	
	DefaultParser.parse_file(path)
end

private

def self.adapter_specific_class(model_class,ref)
	return nil unless LightModels::Java::PROP_ADAPTERS[model_class]
	LightModels::Java::PROP_ADAPTERS[model_class][ref.name]
end

end
end