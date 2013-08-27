require 'java'
require 'rubygems'
require 'emf_jruby'
require 'lightmodels'

# TODO put in modules...

module JavaModel

IJavaOptions = org.emftext.language.java.resource.java.IJavaOptions

def self.create_resource_set()
	resource_set = org.eclipse.emf.ecore.resource.impl.ResourceSetImpl.new
	resource_set.getLoadOptions.put(IJavaOptions.DISABLE_LAYOUT_INFORMATION_RECORDING,true)
	rf = org.emftext.language.java.resource.java.mopp.JavaResourceFactory.new
	resource_set.getResourceFactoryRegistry.getExtensionToFactoryMap.put('java',rf)
	resource_set
end

def self.get_resource(resource_set,path)
	resource_set.getResource(org.eclipse.emf.common.util.URI.createFileURI(path),true)
end

def self.eobject_class_qname(clazz)
	raise "not implemented (ParentConcreteClassifier: #{clazz.getParentConcreteClassifier}" if clazz.getParentConcreteClassifier!=clazz
	clazz.getContainingPackageName.join('.')+"."+clazz.name
end

def self.all_direct_content(root)
	contents = []
	root.keys.each do |k|
		if k.start_with? 'relcont_' and root[k]
			#puts "Considering rel #{k} = #{root[k]}"
			if root[k].is_a? Array 
				root[k].each do |c|
					contents << c
				end
			else
				contents << root[k]
			end
		end
	end
	contents
end

def self.all_deep_content(root)
	contents = []
	all_direct_content(root).each do |c|
		contents << c
		contents.concat(all_deep_content(c))
	end
	contents
end

def self.get_deep_content_of_type(root,type)
	all_deep_content(root).select {|o| o['type']==type}
end

def self.get_specific_deep_content(root,type,&block)
	get_deep_content_of_type(root,type).find &block
end

class EClassClassAdapter

	def adapt(eobject,map)
		map['attr_fullname'] = JavaModel.eobject_class_qname(eobject)
	end

end

def self.getter(field)
	getter_nb_name = 'get' + field.name.slice(0,1).capitalize + field.name.slice(1..-1)
	getter_b_name  = 'is' + field.name.slice(0,1).capitalize + field.name.slice(1..-1)
	methods = field.eContainer.members.select {|m| m.java_kind_of? org.emftext.language.java.members.ClassMethod}
	getter = methods.find {|m| m.name==getter_b_name or m.name==getter_nb_name}
	getter
end

def self.setter(field)
	setter_name = 'set' + field.name.slice(0,1).capitalize + field.name.slice(1..-1)
	methods = field.eContainer.members.select {|m| m.java_kind_of? org.emftext.language.java.members.ClassMethod}
	setter = methods.find {|m| m.name==setter_name}
	setter
end

def self.field_from_getter(getter)
	if (getter.name.start_with? 'get' and getter.name.length>3) or (getter.name.start_with? 'is' and getter.name.length>2)
		field_name = getter.name.slice(3,1).downcase + getter.name.slice(4..-1) if getter.name.start_with? 'get'
		field_name = getter.name.slice(2,1).downcase + getter.name.slice(3..-1) if getter.name.start_with? 'is'
		#puts "Field name for getter #{getter.name} #{field_name}"
		fields = getter.eContainer.members.select {|m| m.java_kind_of? org.emftext.language.java.members.Field}
		field = fields.find {|f| f.name==field_name}
		return field
	else
		return nil
	end	
end

def self.field_from_setter(setter)
	if setter.name.start_with? 'set' and setter.name.length>3
		field_name = setter.name.slice(3,1).downcase + setter.name.slice(4..-1) if setter.name.start_with? 'set'
		#field_name = getter.name.slice(2,1).downcase + getter.name.slice(3..-1) if getter.name.start_with? 'is'
		#puts "Field name for getter #{getter.name} #{field_name}"
		fields = setter.eContainer.members.select {|m| m.java_kind_of? org.emftext.language.java.members.Field}
		field = fields.find {|f| f.name==field_name}
		return field
	else
		return nil
	end	
end

class EClassClassMethodAdapter

	def adapt(eobject,map)
		field = JavaModel.field_from_getter(eobject)
		map['attr_getter'] = field!=nil
		map['relnoncont_getterFor'] = LightModels::Serialization::serialization_id(field) if field
		map['relnoncont_getterFor'] = nil unless field

		field = JavaModel.field_from_setter(eobject)
		map['attr_setter'] = field!=nil
		map['relnoncont_setterFor'] = LightModels::Serialization::serialization_id(field) if field
		map['relnoncont_setterFor'] = nil unless field
	end

end

class EClassFieldAdapter

	def adapt(eobject,map)
		getter = JavaModel.getter(eobject)
		map['relnoncont_getter'] = LightModels::Serialization::serialization_id(getter) if getter
		map['relnoncont_getter'] = nil unless getter
	end

end

ADAPTERS_MAP =
	{
		'http://www.emftext.org/java/classifiers#Class'=> EClassClassAdapter.new,
		'http://www.emftext.org/java/members#ClassMethod'=> EClassClassMethodAdapter.new,
		'http://www.emftext.org/java/members#Field'=> EClassFieldAdapter.new
	}

def self.jsonize_java_obj(root)
	LightModels::Serialization::jsonize_obj(root,ADAPTERS_MAP)
end

end