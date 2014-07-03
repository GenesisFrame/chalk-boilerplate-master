# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chalk-boilerplate/version'

Gem::Specification.new do |gem|
  gem.name          = 'chalk-boilerplate'
  gem.version       = Chalk::Boilerplate::VERSION
  gem.authors       = ['Greg Brockman']
  gem.email         = ['gdb@stripe.com']
  gem.description   = 'Generators for various boilerplate'
  gem.summary       = <<EOF
Contains boilerplate generators for a couple of common use-cases, such
as generating a new gem (as a layer on top of `boiler gem`):

  boiler gem <gemname>

Or an executable:

  boiler script <script>
EOF
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'chalk-rake'
  gem.add_dependency 'escort'
  gem.add_dependency 'chalk-log'
  gem.add_dependency 'rubysh'
end
