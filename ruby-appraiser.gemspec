# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-appraiser/version'

Gem::Specification.new do |gem|
  gem.name          = 'ruby-appraiser'
  gem.version       = RubyAppraiser::VERSION
  gem.authors       = ['Ryan Biesemeyer']
  gem.email         = ['ryan@simplymeasured.com']
  gem.description   = 'Run multiple code-quality tools against staged changes'
  gem.summary       = 'A Common interface/executor for code quality tools'
  gem.homepage      = 'https://github.com/simplymeasured'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
