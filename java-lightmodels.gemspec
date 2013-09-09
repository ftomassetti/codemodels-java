Gem::Specification.new do |s|
  s.platform    = 'java'
  s.name        = 'java-lightmodels'
  s.version     = '0.1.5'
  s.date        = '2013-09-09'
  s.summary     = "Create EMF models of Java"
  s.description = "Create EMF models of Java code and serialize them in JSON"
  s.authors     = ["Federico Tomassetti"]
  s.email       = 'f.tomassetti@gmail.com'
  s.homepage    = 'http://federico-tomassetti.it'
  s.files       = Dir['./lib/*.rb'] + Dir['./lib/java-lightmodels/*.rb'] + Dir['./lib/jars/*.jar']
  s.add_runtime_dependency 'emf_jruby', '>= 0.1.2'
  s.add_runtime_dependency 'lightmodels'
  s.add_runtime_dependency 'json'
end
