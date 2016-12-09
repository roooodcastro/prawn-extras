$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'prawn/extra_helpers/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'prawn-extra_helpers'
  s.version     = Prawn::ExtraHelpers::VERSION
  s.authors     = ['Rodrigo Castro']
  s.email       = ['rod.c.azevedo@gmail.com']
  s.homepage    = 'https://github.com/roooodcastro/prawn-extras'
  s.summary     = 'Extra functions for the great Prawn gem'
  s.description = 'Extra functions for the great Prawn gem'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile',
                'README.md']

  s.add_dependency 'rails', '>= 4.2.0'
  s.add_dependency 'prawn'

  s.add_development_dependency 'rubocop'
end
