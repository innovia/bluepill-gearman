require "bluepill-nagios/version"
require "send_nsca"
require "bluepill"

module Bluepill
  module Nagios
    class Nsca < Bluepill::Trigger
      # Called by bluepill when a "checks :nsca" is declared in pill file
      # @param [Bluepill::Process] process object from Bluepill see http://rdoc.info/github/arya/bluepill/master/Bluepill/Process
      # @param [Hash] options available options:
      #   * nscahost: the host hosting the nsca daemon. mandatory
      #   * hostname: the host defined in nagios to be hosting the service (default: hostname -f)
      #   * service: the service declared in nagios (default: the bluepill process name)
      #   See checks https://github.com/arya/bluepill for the syntax to pass those options
      def initialize(process, options={})
        @default_args = {
          :nscahost => options.delete(:nscahost),
          :port => options.delete(:port) || 5667,
          :hostname => options.delete(:host) || `hostname -f`.chomp,
          :service => options.delete(:service) || process.name
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
          send_nsca(_args)
        end
      end

      protected
      def send_nsca(args)
        begin
          nsca_connection = SendNsca::NscaConnection.new(args)
          nsca_connection.send_nsca 
          logger.debug("nsca server notified") if logger
        rescue => e
          logger.warning("failed to reach the nsca server: #{e}") if logger 
        end
      end
    end
  end
end
