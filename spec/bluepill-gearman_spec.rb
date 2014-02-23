require 'minitest/spec'
require 'test/unit'
require 'mocha/test_unit'
require 'minitest/autorun'
require 'mocha'
require './lib/bluepill-gearman'

describe Bluepill::Gearman::SendGearman do
  let(:process) { Minitest::Mock.new }
  let(:notifier) {Bluepill::Gearman::SendGearman.new(process, {:gearman_server => 'remotehost', :host => 'localhost'})}

  it "should create a default_args instance variable to store default connection parameters" do
    process.expect(:name, 'my_process')
    notifier.instance_variable_get(:@default_args).must_equal({:gearman_job_server => ['remotehost:4730'], :host => 'localhost', :service => 'my_process', :queue => 'check_results', :encryption => false, :key => ''})
  end

  it "should notify gearman_server of a critical error via send_gearman when a transition to down occurs" do
    process.expect(:name, 'my_process')
    transition = Minitest::Mock.new
    transition.expect(:to_name,:down)
    notifier.expects(:send_gearman).with({:gearman_server => ['remotehost:4730'], :host => 'localhost', :service => 'my_process', :return_code => 2, :status => "Bluepill reported process down at #{Time.now}"})
    notifier.notify(transition)
  end

  it "should notify gearman_server of a warning error via send_gearman when a transition to unmonitored occurs" do
    process.expect(:name, 'my_process')
    transition = Minitest::Mock.new
    transition.expect(:to_name,:unmonitored)
    notifier.expects(:send_gearman).with({:gearman_server => ['remotehost:4730'], :host => 'localhost', :service => 'my_process', :return_code => 1, :status => "Bluepill stopped monitoring at #{Time.now}"})
    notifier.notify(transition)
  end

  it "should notify gearman_server that everything is ok via send_gearman when a transition to up occurs" do
    process.expect(:name, 'my_process')
    transition = Minitest::Mock.new
    transition.expect(:to_name,:up)
    notifier.expects(:send_gearman).with({:gearman_server => ['remotehost:4730'], :host => 'localhost', :service => 'my_process', :return_code => 0, :status => "Running"})
    notifier.notify(transition)
  end
end
