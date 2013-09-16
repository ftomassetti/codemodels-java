require 'test/unit'
require 'java-lightmodels'
require 'rgen/ecore/ecore'

class TestMetamodel < Test::Unit::TestCase

	RGenString = RGen::ECore::EString
	RGenBoolean = RGen::ECore::EBoolean
	RGenInt = RGen::ECore::EInt

	def get_relation(rgen_class,rel_name,type=nil,multiplicity=nil)
		type = get_metaclass(type) if type
		rel = rgen_class.ecore.eAllReferences.find {|r| r.name==rel_name}
		if rel and type
			raise "Wrong type: expected #{type.ecore}, found: #{rel.eType}" unless type.ecore===rel.eType
		end
		if rel and multiplicity
			case multiplicity
			when :many
				raise "Wrong type: expected many, found single" unless rel.many
			when :single
				raise "Wrong type: expected single, found many" if rel.many								
			else
				raise "Illegal multiplicity: #{multiplicity}"
			end
		end
		rel
	end

	def get_attr(rgen_class,name,type=nil,multiplicity=nil)
		att = rgen_class.ecore.eAllAttributes.find {|a| a.name==name}
		if att and type
			raise "Wrong type: expected #{type}, found: #{att.eType}" unless type===att.eType
		end
		if att and multiplicity
			case multiplicity
			when :many
				raise "Wrong type: expected many, found single" unless att.many
			when :single
				raise "Wrong type: expected single, found many" if att.many				
			else
				raise "Illegal multiplicity: #{multiplicity}"
			end
		end		
		att
	end

	def assert_extend(rgen_class,super_class)
		assert rgen_class.superclass == get_metaclass(super_class)
	end

	def get_metaclass(name)
		LightModels::Java.const_get(name)
	end

	def test_comment_unit_exist
		assert get_metaclass('Comment')
	end

	def test_comment_has_attr_content
		c = get_metaclass('Comment')
		assert get_attr(c,'content',RGenString)
	end

	def test_name_expr_exist
		assert get_metaclass('NameExpr')
	end

	def test_name_expr_has_attr_name
		c = get_metaclass('NameExpr')
		assert get_attr(c,'name',RGenString)
	end

	def test_compilatioun_unit_exist
		assert get_metaclass('CompilationUnit')
	end

	def test_compilatioun_unit_has_relations
		cu = get_metaclass('CompilationUnit')
		#assert get_relation(cu,'comments')
		assert get_relation(cu,'imports')
		assert get_relation(cu,'package')
		assert get_relation(cu,'types')
	end

	def test_import_declaration_has_attr_asterisk
		c = get_metaclass('ImportDeclaration')
		assert get_attr(c,'asterisk',RGenBoolean)
	end

	def test_import_declaration_has_rel_name
		c = get_metaclass('ImportDeclaration')
		assert get_relation(c,'name','NameExpr')		
	end

	def test_type_declaration
		c = get_metaclass('TypeDeclaration')
		assert get_relation(c,'members','BodyDeclaration',:many)
		#assert get_attr(c,'modifiers',RGenInt,:single) #ignored!
		assert get_attr(c,'name',RGenString,:single)
	end

	def test_body_declaration
		c = get_metaclass('BodyDeclaration')
		#assert get_relation(c,'javaDoc','JavadocComment',:single)
		assert get_relation(c,'annotations','AnnotationExpr',:many)
	end

	def test_method_declaration
		c = get_metaclass('MethodDeclaration')
		assert_extend c,'BodyDeclaration'
		# inherited from body declaration
		#assert get_relation(c,'javaDoc','JavadocComment',:single)
		assert get_relation(c,'annotations','AnnotationExpr',:many)
		# declared
		# these two are being ignored
		# assert get_attr(c,'arrayCount',RGenInt,:single)
		# assert get_attr(c,'modifiers',RGenInt,:single)
		assert get_relation(c,'body','BlockStmt',:single)		
		assert get_attr(c,'name',RGenString,:single)
		assert get_relation(c,'parameters','Parameter',:many)
		assert get_relation(c,'throws','NameExpr',:many)
		assert get_relation(c,'type','Type',:single)
		assert get_relation(c,'typeParameters','TypeParameter',:many)
	end

	def test_method_assign_expr
		c = get_metaclass('AssignExpr')
		# assert get_attr(c,'operator',RGenString,:single) # ignored
		assert get_relation(c,'target','Expression')
		assert get_relation(c,'value','Expression')
	end

end