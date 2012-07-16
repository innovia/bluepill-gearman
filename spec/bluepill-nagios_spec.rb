require 'minitest/spec'
require 'minitest/autorun'
require 'mocha'
require './lib/bluepill-nagios'

describe Bluepill::Nagios::Notifier do
  let(:process) { Minitest::Mock.new }
  let(:notifier) {Bluepill::Nagios::Notifier.new(process, {nscahost: 'remotehost', host: 'localhost'})}

  it "should create a default_args instance variable to store default connection parameters" do
    process.expect(:name, 'my_process')
    notifier.instance_variable_get(:@default_args).must_equal({nscahost: 'remotehost', port: 5667, hostname: 'localhost', service: 'my_process', return_code: 0})
  end

  it "should notify nagios of a critical error via send_nsca when a transition to down occurs" do
    process.expect(:name, 'my_process')
    transition = Minitest::Mock.new
    transition.expect(:to_name,:down)
    notifier.expects(:send_nsca).with({nscahost: 'remotehost', port: 5667, hostname: 'localhost', service: 'my_process', return_code: 0, status: 2})
    notifier.notify(transition)
  end

  it "should notify nagios of a warning error via send_nsca when a transition to unmonitored occurs" do
    process.expect(:name, 'my_process')
    transition = Minitest::Mock.new
    transition.expect(:to_name,:unmonitored)
    notifier.expects(:send_nsca).with({nscahost: 'remotehost', port: 5667, hostname: 'localhost', service: 'my_process', return_code: 0, status: 1})
    notifier.notify(transition)
  end

  it "should notify nagios that everything is ok via send_nsca when a transition to up occurs" do
    process.expect(:name, 'my_process')
    transition = Minitest::Mock.new
    transition.expect(:to_name,:up)
    notifier.expects(:send_nsca).with({nscahost: 'remotehost', port: 5667, hostname: 'localhost', service: 'my_process', return_code: 0, status: 0})
    notifier.notify(transition)
  end
end
