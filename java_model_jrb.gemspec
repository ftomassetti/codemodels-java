Gem::Specification.new do |s|
  s.platform    = 'java'
  s.name        = 'java_model_jrb'
  s.version     = '0.1.3'
  s.date        = '2013-08-26'
  s.summary     = "Create EMF models of Java"
  s.description = "Create EMF models of Java code and serialize them in JSON"
  s.authors     = ["Federico Tomassetti"]
  s.email       = 'f.tomassetti@gmail.com'
  s.homepage    = 'http://federico-tomassetti.it'
  s.files       = [
  	"lib/java_model_jrb.rb",
    "lib/java_model/java_to_json.rb",
    "lib/java_model/java_models_builder.rb",
  	"lib/jars/org.emftext.commons.antlr3_4_0_3.4.0.v201207310007.jar",
    "lib/jars/org.emftext.commons.layout_1.4.1.v201207310007.jar",
    "lib/jars/org.emftext.language.java.resource.java_1.4.0.v201207310007.jar",
    "lib/jars/org.emftext.language.java.resource_1.4.0.v201207310007.jar",
    "lib/jars/org.emftext.language.java_1.4.0.v201207310007.jar"]

  s.add_runtime_dependency 'emf_jruby', '>= 0.1.2'
  s.add_runtime_dependency 'lightmodels'
  s.add_runtime_dependency 'json'
end
