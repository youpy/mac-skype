require 'uuid'
require 'timeout'

module Mac
  module Skype
    class Api
      attr_accessor :callback, :attach

      def initialize
        @attach = 0
        init
      end

      def receive_event(response)
        if callback
          callback.call(response)
        end
      end
    end

    class Agent
      def initialize
        @callbacks = {}

        on_receive = Proc.new do |response|
          if response =~ /^#/
            _, id, response_body = response.match(/^#([^\s]+) (.+)/).to_a

            if @callbacks[id]
              @callbacks[id].call(response_body)
              @callbacks.delete(id)
            end
          end
        end

        api.callback = on_receive
      end

      def skype_running?
        api.running?
      end

      def connected?
        api.attach == 1
      end

      def connect(stop_after = 0)
        api.connect if !connected?

        while !connected?
          api.run_loop(stop_after)
          sleep 0.1
        end
      end

      def disconnect
        api.disconnect
        api.attach = 0
      end

      def send_command_async(command_str, &callback)
        id = generate_id

        @callbacks[id] = callback
        api.send_command('#%s %s' % [id, command_str])
      end

      def send_command_sync(command_str)
        response = nil

        callback = Proc.new do |res|
          response = res
        end

        send_command_async(command_str, &callback)

        timeout(5) do
          while response.nil?
            api.run_loop(0)
            sleep 0.1
          end
        end

        response
      end

      def run_forever
        loop do
          api.run_loop(0)
          sleep 0.1
        end
      end

      alias send_command send_command_sync

      private

      def generate_id
        uuid.generate
      end

      def api
        @api ||= Api.new
      end

      def uuid
        @uuid ||= UUID.new
      end
    end
  end
end
