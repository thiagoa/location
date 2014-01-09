$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "location/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "location"
  s.version     = Location::VERSION
  s.authors     = ["Thiago A. Silva"]
  s.email       = ["thiagoaraujos@gmail.com"]
  s.summary     = "Location related utilities: polymorphic address models, address autocomplete and maps"
  s.description = "Location related utilities: polymorphic address models, address autocomplete and maps"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails", '2.14.0'
  s.add_development_dependency "shoulda-matchers", '2.4.0'
  s.add_development_dependency "factory_girl_rails", '4.3.0'
  s.add_development_dependency "guard-rspec", '4.2.0'
  s.add_development_dependency "webmock", '1.16.1'
end
