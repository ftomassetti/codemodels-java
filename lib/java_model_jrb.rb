lib = $:.select{|e| e.gsub('java_model_jrb').count>0}
if lib.count==1
	lib_path = lib[0]
elsif File.exist?('./lib')
	lib_path = './lib'
else
	raise 'library java_model_jrb not in $: and neither in local lib dir'
end

Dir[lib_path+"/jars/*.jar"].each do |jar|
	require jar
end

require 'java_model/java_to_json'