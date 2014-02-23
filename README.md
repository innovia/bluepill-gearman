# Bluepill::Gearman

Send bluepill events to gearman server via send gearman

## Installation

Add this line to your application's Gemfile:

    gem 'bluepill-gearman', 

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bluepill-gearman

## Usage

Require the bluepill-gearman gem and add a check named :gearman in your pill configuration file.

Available options are:
* gearman_server: the gearman server where you want to send your passive checks
* port: the port where nsca daemon is listening (default: 4730)
* hostname: the host defined in your nagios configuration (default: hostname -f)
* service: the service name defined in the nagios configuration (default: bluepill configuration process name)
* queue: the queue name to process the jobs (default: check_results)

Example:

```
require 'bluepill-gearman'
Bluepill.application("test") do |app|
  app.process("test") do |process|
    process.start_command = "bundle exec ./test.rb"
    process.pid_file = "/var/run/test.pid"
    process.daemonize = true
    process.checks :gearman, :gearman_server => 'my.gearman.server'
  end
end
```

Note:
does not send job via encryption - simply encoded64

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
