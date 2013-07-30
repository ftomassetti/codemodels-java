require 'java'
require 'rubygems'
require 'emf_jruby'
require 'json'
require 'zip/zipfilesystem'
require 'java_to_json_lib'

$PWD = File.dirname(__FILE__)

raise "Usage: java_to_json <sources> <models>" unless ARGV.count==2

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

def translate_dir(src,dest,src_extension,dest_extension,&translate_file)
	puts "== #{src} -> #{dest} ==" if $VERBOSE
	Dir["#{src}/*"].each do |fd|		
		if File.directory? fd
			basename = File.basename(fd)
			translate_dir("#{src}/#{basename}","#{dest}/#{basename}",src_extension,dest_extension,&translate_file)
		else
			if File.extname(fd)==".#{src_extension}"
				translated_simple_name = "#{File.basename(fd, ".#{src_extension}")}.#{dest_extension}"
				translated_name = "#{dest}/#{translated_simple_name}"
				puts "* #{fd} --> #{translated_name}" if $VERBOSE
				translate_file.call(fd,translated_name)
			end
		end
	end
end

$resource_set = create_resource_set()

translate_dir($SRC,$DEST,'java','json') do |src,dest|
	if not File.exist? dest 
		puts "<Model from #{src}>"
	
		#file = java.io.File.new src
		# java_resource = JavaResourceUtil.getResource file
		java_resource = get_resource($resource_set, src)

		raise "wrong number of roots" unless java_resource.contents.size == 1
		root = java_resource.contents.get(0)

		$nextId = 1
		res = jsonize_java_obj(root)

		dest_dir = File.dirname(dest)
		FileUtils.mkdir_p(dest_dir) 
		File.open(dest, 'w') do |file| 		
			file.write(JSON.pretty_generate(res,:max_nesting => 500))
		end
	end
end
