require 'codemodels'
require 'codemodels/javaparserwrapper'

module CodeModels
module Java

class Parser < CodeModels::Javaparserwrapper::ParserJavaWrapper

	java_import 'japa.parser.JavaParser'
	java_import 'java.io.FileInputStream'
	java_import 'java.io.ByteArrayInputStream'

	def containment_pos(node)
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
	def corresponding_node(model_element,node_tree)
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

	def node_tree_from_code(code)
		sis = ByteArrayInputStream.new(code.to_java_bytes)
		node_tree = JavaParser.parse(sis)
		sis.close
		node_tree
	end

	def corresponding_node_from_code(model_element,code)
		sis = ByteArrayInputStream.new(code.to_java_bytes)
		node_tree = JavaParser.parse(sis)
		sis.close
		corresponding_node(model_element,node_tree)
	end

	def parse_code(code)	
		node_to_model(node_tree_from_code(code))
	end

	def parse_file(path)	
		DefaultParser.parse_file(path)
	end

	def get_corresponding_metaclass(node)
		node_class = node.class
		name = CodeModels::Javaparserwrapper::Utils.simple_java_class_name(node_class)
		name = "#{(node.operator.name).proper_capitalize}BinaryExpr" if name=='BinaryExpr'
		if node.class.to_s=='Java::JapaParserAstBody::MethodDeclaration'
			if node.parent.class.to_s=='Java::JapaParserAstExpr::ObjectCreationExpr'
				name = 'ClassMethodDeclaration'
			elsif node.parent.class.to_s=='Java::JapaParserAstBody::EnumDeclaration'
				name = 'ClassMethodDeclaration' 
			elsif node.parent.interface?				
				name = 'InterfaceMethodDeclaration'
			else
				name = 'ClassMethodDeclaration'
			end
		end
		return Java.const_get(name)
	end

private

	def adapter_specific_class(model_class,ref)
		return nil unless CodeModels::Java::PROP_ADAPTERS[model_class]
		CodeModels::Java::PROP_ADAPTERS[model_class][ref.name]
	end

end

DefaultParser = Parser.new

def self.parse_code(code)
	DefaultParser.parse_code(code)
end

end
end