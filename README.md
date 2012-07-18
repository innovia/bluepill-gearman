# Bluepill::Nagios

Send bluepill events to nagios via nsca

## Installation

Add this line to your application's Gemfile:

    gem 'bluepill-nagios'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bluepill-nagios

## Usage

Require the bluepill-nagios gem and add a check named :notifier in your pill configuration file.

Available options are:
* nscahost: the host where you want to send your events
* port: the port where nsca daemon is listening (default: 5667)
* hostname: the host defined in your nagios configuration (default: hostname -f)
* service: the service name defined in the nagios configuration (default: bluepill configuration process name)

Example:

```
require 'bluepill-nagios'
Bluepill.application("test") do |app|
  app.process("test") do |process|
    process.start_command = "bundle exec ./test.rb"
    process.pid_file = "/var/run/test.pid"
    process.daemonize = true
    process.checks :nsca, :nscahost => 'my.nagios.host'
  end
end
```

Don't forget to set up the nsca daemon on the remote host.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
