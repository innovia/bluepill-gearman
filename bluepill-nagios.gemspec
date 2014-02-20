# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bluepill-nagios/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ami Mahloof"]
  gem.email         = ["ami.mahloof@gmail.com"]
  gem.description   = %q{send events to nagios when a bluepill process state changes}
  gem.summary       = %q{send events to nagios via the send gearman when a bluepill monitored process triggers a state change}
  gem.homepage      = "http://github.com/innovia/bluepill-nagios"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.name          = "bluepill-nagios"
  gem.require_paths = ["lib"]
  gem.add_dependency "bluepill"
  gem.add_dependency "gearman-ruby"
  gem.version       = Bluepill::Nagios::VERSION
end
