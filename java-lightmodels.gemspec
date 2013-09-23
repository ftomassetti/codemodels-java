Gem::Specification.new do |s|
  s.platform    = 'java'
  s.name        = 'java-lightmodels'
  s.version     = '0.2.0'
  s.date        = '2013-09-11'
  s.summary     = "Create EMF models of Java"
  s.description = "Create EMF models of Java code and serialize them in JSON"
  s.authors     = ["Federico Tomassetti"]
  s.email       = 'f.tomassetti@gmail.com'
  s.homepage    = 'https://github.com/ftomassetti/java-lightmodels'
  s.license     = "APACHE2"
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"] + Dir['./lib/jars/*.jar']

  s.add_runtime_dependency 'lightmodels'
  s.add_runtime_dependency 'json'

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"  
  s.add_development_dependency "simplecov"
  s.add_development_dependency "rubygems-tasks"
end
