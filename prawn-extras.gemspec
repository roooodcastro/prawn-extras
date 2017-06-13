$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'prawn/extras/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'prawn-extras'
  s.version     = Prawn::Extras::VERSION
  s.authors     = ['Rodrigo Castro']
  s.email       = ['rod.c.azevedo@gmail.com']
  s.homepage    = 'https://github.com/roooodcastro/prawn-extras'
  s.summary     = 'Extra functions for the great Prawn gem'
  s.description = 'Extra functions for the great Prawn gem'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile',
                'README.md']

  s.add_dependency 'prawn'

  s.add_development_dependency 'rspec', '~> 3.6.0'
  s.add_development_dependency 'rubocop'
end
