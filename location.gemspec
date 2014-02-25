$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "location/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "location"
  s.version     = Location::VERSION
  s.homepage    = 'http://github.com/thiagoa/location'
  s.authors     = ["Thiago A. Silva"]
  s.email       = ["thiagoaraujos@gmail.com"]
  s.license     = 'MIT'
  s.summary     = "Location and address related utilities"
  s.description = "Polymorphic address models, address normalization, address web services, address autocomplete, maps"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", '~> 4.0', '>= 4.0.0'

  s.add_development_dependency "sqlite3", '1.3.8'
  s.add_development_dependency "super_form", '~> 0.1'
  s.add_development_dependency "rspec-rails", '2.14.0'
  s.add_development_dependency "capybara", '2.2.0'
  s.add_development_dependency "shoulda-matchers", '2.4.0'
  s.add_development_dependency "factory_girl_rails", '4.3.0'
  s.add_development_dependency "guard-rspec", '4.2.0'
  s.add_development_dependency "webmock", '1.16.1'
  s.add_development_dependency "virtus", '1.0.1'
  s.add_development_dependency "pry-rails", '0.3.2'
  s.add_development_dependency "thor", '0.18.1'
  s.add_development_dependency "simplecov", '0.8.2'
  s.add_development_dependency "activemodel", '4.0.3'
end
