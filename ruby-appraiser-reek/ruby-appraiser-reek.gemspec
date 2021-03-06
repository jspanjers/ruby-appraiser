# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-appraiser-reek/version'

require 'fileutils'
FileUtils::cd(File::dirname(__FILE__))

Gem::Specification.new do |gem|
  gem.name          = 'ruby-appraiser-reek'
  gem.version       = RubyAppraiserReek::VERSION
  gem.authors       = ['Ryan Biesemeyer']
  gem.email         = ['ryan@simplymeasured.com']
  gem.description   = %q{Reek adapter for ruby-appraiser}
  gem.summary       = %q{Run Reek inside RubyAppraiser}
  gem.homepage      = 'https://github.com/simplymeasured'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'reek'
  gem.add_runtime_dependency 'ruby-appraiser'
end
