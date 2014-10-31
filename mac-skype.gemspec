# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mac-skype/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["youpy"]
  gem.email         = ["youpy@buycheapviagraonlinenow.com"]
  gem.description   = %q{A library to use Skype from Mac}
  gem.summary       = %q{A library to use Skype from Mac}
  gem.homepage      = ""
  gem.platform      = Gem::Platform::CURRENT
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "mac-skype"
  gem.require_paths = ["lib"]
  gem.extensions    = ["ext/skype_api/extconf.rb"]
  gem.version       = Mac::Skype::VERSION

  gem.add_dependency('uuid')
  gem.add_dependency('Ruby4Skype')

  gem.add_development_dependency('rspec', ['~> 2.8.0'])
  gem.add_development_dependency('rake')
  gem.add_development_dependency('mac-skype')
end
