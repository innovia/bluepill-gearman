# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bluepill-nagios/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Vincent Hellot"]
  gem.email         = ["hellvinz@gmail.com"]
  gem.description   = %q{send events to nagios when a bluepill process state changes}
  gem.summary       = %q{send events to nagios via the ncsa plugin when a bluepill monitored process triggers a state change}
  gem.homepage      = "http://github.com/hellvinz/bluepill-nagios"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "bluepill-nagios"
  gem.require_paths = ["lib"]
  gem.add_dependency "bluepill"
  gem.add_dependency "send_nsca"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "mocha"
  gem.test_files = Dir.glob('spec/*_spec.rb')
  gem.version       = Bluepill::Nagios::VERSION
end
