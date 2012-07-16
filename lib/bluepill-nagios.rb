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
          hostname: options[:host]||`hostname -f`,
          service: process.name,
          return_code: 0
        }
        super
      end
      def notify(transition)
        status = nil
        case transition.to_name
        when :down
          status = 2 
        when :unmonitored
          status = 1 
        when :up
          status = 0 
        end
        if status
          args = @default_args.merge({:status => status})
        end
        send_nsca(args) if status
      end

      def send_nsca(args)
        nsca_connection = SendNsca::NscaConnection.new(args)
        nsca_connection.send_nsca 
      end
    end
  end
end
