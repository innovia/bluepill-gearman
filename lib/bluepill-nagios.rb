require "bluepill-nagios/version"
require 'gearman'
require "bluepill"
require 'base64'

module Bluepill
  module Nagios
    class Send_Gearman < Bluepill::Trigger
      <<-INFO
        Called by bluepill when a "checks :send_gearman" is declared in pill file
        @param [Bluepill::Process] process object from Bluepill see http://rdoc.info/github/arya/bluepill/master/Bluepill/Process
        @param [Hash] options available options:
          * gearman_server: the Gearman Server. mandatory
          * gearman_port: the gearman server port or default to 4730
          * hostname: the host defined in nagios to be hosting the service (default: hostname -f)
          * service: the service declared in nagios (default: the bluepill process name)
          * queue: default queue is 'check_results'
          See checks https://github.com/arya/bluepill for the syntax to pass those options
      INFO

      def initialize(process, options={})
        @default_args = {
          :gearman_server => ["#{options.delete(:gearman_server)}:#{options.delete(:gearman_port) || 4730}"],
          :host => options.delete(:host) || `hostname -f`.chomp,
          :service => options.delete(:service) || process.name,
          :queue => options.delete(:queue) || 'check_results'
        }
        super
      end
      
      # Called by bluepill when process states changes. Notifies the nagios when:
      # * the process goes to :unmonitored notifies warning
      # * the process goes to :down notifies critical
      # * the process goes to :up notifies ok
      def notify(transition)
        _return_code, _status = case transition.to_name
        when :down
          [2, "Bluepill reported process down at #{Time.now}"]
        when :unmonitored
          [1 , "Bluepill stopped monitoring at #{Time.now}"]
        when :up
          [0 , "Running"]
        else
          [nil, nil]
        end
        if _status and _return_code
          _args = @default_args.merge({:status => _status, :return_code => _return_code})
          send_gearman(_args)
        end
      end

      protected
      def send_gearman(args)
        begin
          client  = Gearman::Client.new(args[:gearman_server])
          taskset = Gearman::TaskSet.new(client)
          job = <<-EOT
type=passive
host_name=#{args[:host]}
service_description=#{args[:service]}
start_time=#{Time.now.to_i}.0
finish_time=#{Time.now.to_i}.0
latency=0.0
return_code=#{args[:return_code]}
output=#{args[:status]}
EOT

          encoded_job = Base64.encode64(job)
          task = Gearman::Task.new(args[:queue], encoded_job)
          result = taskset.add_task(task)

          logger.debug("Sent Job to Gearman Server: #{result}") if logger
        rescue Exception => e
          logger.warning("Failed to send job to the Gearman Server: #{e}") if logger 
        end
      end
    end
  end
end
