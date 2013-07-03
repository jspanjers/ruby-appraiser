# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-appraiser-rubocop/version'

require 'fileutils'
FileUtils::cd(File::dirname(__FILE__))

Gem::Specification.new do |gem|
  gem.name          = 'ruby-appraiser-rubocop'
  gem.version       = RubyAppraiserRubocop::VERSION
  gem.authors       = ['Ryan Biesemeyer']
  gem.email         = ['ryan@simplymeasured.com']
  gem.description   = %q{Rubocop adapter for ruby-appraiser}
  gem.summary       = %q{Run Rubocop inside RubyAppraiser}
  gem.homepage      = 'https://github.com/simplymeasured'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'rubocop', '~> 0.9'
  gem.add_runtime_dependency 'ruby-appraiser', '~> 1.0', '>= 1.0.3'
end
