require 'rgen/metamodel_builder'
require 'java'

class String
	def remove_postfix(postfix)
		raise "'#{self}'' have not the right postfix '#{postfix}'" unless end_with?(postfix)
		self[0..-(1+postfix.length)]
	end

	def remove_prefix(prefix)
		raise "'#{self}'' have not the right prefix '#{prefix}'" unless start_with?(prefix)
		self[prefix.length..-1]
	end

	def uncapitalize 
    	self[0, 1].downcase + self[1..-1]
  	end
end	

module LightModels

module Java

	JavaString  = ::Java::JavaClass.for_name("java.lang.String")
	JavaList    = ::Java::JavaClass.for_name("java.util.List")
	JavaBoolean = ::Java::boolean.java_class
	JavaInt = ::Java::int.java_class

	MappedAstClasses = {}

	def self.wrap(ast_names)		

		# first create all the classes
		ast_names.each do |ast_name|
			java_class = ::Java::JavaClass.for_name("japa.parser.ast.#{ast_name}")
			java_super_class = java_class.superclass
			if java_super_class.name == 'japa.parser.ast.Node'
				super_class = RGen::MetamodelBuilder::MMBase
			else
				raise "Super class #{java_super_class.name} of #{java_class.name}" unless MappedAstClasses[java_super_class]
				super_class = MappedAstClasses[java_super_class]
			end
			puts "Java Super Class: #{java_super_class.name}"
			ast_class = java_class.ruby_class
			# TODO it should extend the right class...
			c = Class.new(super_class)
			MappedAstClasses[java_class] = c
			Java.const_set simple_java_class_name(ast_class), c
		end

		# then add all the properties and attributes
		ast_names.each do |ast_name|
			java_class = ::Java::JavaClass.for_name("japa.parser.ast.#{ast_name}")
			ast_class = java_class.ruby_class
			c = MappedAstClasses[java_class]
				
			c.class_eval do
				ast_class.java_class.declared_instance_methods.select {|m| m.name.start_with?('get')||m.name.start_with?('is') }.each do |m|
					prop_name = LightModels::Java.property_name(m)
					if m.return_type==JavaString
						has_attr prop_name, String
					elsif m.return_type==JavaBoolean
						has_attr prop_name, RGen::MetamodelBuilder::DataTypes::Boolean
					elsif m.return_type==JavaInt
						has_attr prop_name, Integer
					elsif MappedAstClasses.has_key?(m.return_type)
						contains_one_uni prop_name, MappedAstClasses[m.return_type]
					elsif m.return_type==JavaList
	#					puts "Property #{prop_name} is a list"
						type_name = LightModels::Java.get_generic_param(m.to_generic_string)
						last = type_name.index '>'
						type_name = type_name[0..last-1]
						type_ast_class = MappedAstClasses.keys.find{|k| k.name==type_name}
						if type_ast_class
							contains_many_uni prop_name, MappedAstClasses[type_ast_class]
						else
							puts "#{ast_name}) Property (many) #{prop_name} is else: #{type_name}"
						end
					else
						puts "#{ast_name}) Property (single) #{prop_name} is else: #{m.return_type}"
					end
					#type = nil
					#contains_one_uni prop_name, type
				end
			end
		end
	end

	private

	def self.property_name(java_method)
		return java_method.name.remove_prefix('get').uncapitalize if java_method.name.start_with?('get')
		return java_method.name.remove_prefix('is').uncapitalize if java_method.name.start_with?('is')
	end

	def self.simple_java_class_name(java_class)
		name = java_class.name
    	if (i = (r = name).rindex(':')) then r[0..i] = '' end
    	r
  	end

  	def self.get_generic_param(generic_str)
  		return generic_str.remove_prefix('public java.util.List<') if generic_str.start_with?('public java.util.List<')
  		return generic_str.remove_prefix('public final java.util.List<') if generic_str.start_with?('public final java.util.List<')
  		nil
  	end

  	def self.declared_methods(java_class)

  	end

  	wrap ['Comment',
  		'expr.NameExpr',
  		'ImportDeclaration',
	  	'expr.AnnotationExpr',
	  	'PackageDeclaration',
	  	'body.JavadocComment',
	  	'body.BodyDeclaration',
	  	'body.TypeDeclaration',
	  	'CompilationUnit',
	  	'type.ClassOrInterfaceType',
	  	'TypeParameter',
	  	'type.Type',
	  	'body.VariableDeclaratorId',
	  	'body.Parameter',
	  	'stmt.BlockStmt',
	   	
	   	'body.MethodDeclaration']

end

end