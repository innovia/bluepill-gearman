require "bluepill-nagios/version"
require "send_nsca"
require "bluepill"

module Bluepill
  module Nagios
    class Notifier < Bluepill::Trigger
      def initialize(process, options)
        @default_args = {
          nscahost: options[:nscahost],
          port: options[:port]||5667,
          hostname: options[:host]||`hostname -f`.chomp,
          service: options[:service]||process.name
        }
        super
      end
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
