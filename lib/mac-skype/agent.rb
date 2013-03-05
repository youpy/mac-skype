require 'uuid'
require 'timeout'
require 'singleton'

module Mac
  module Skype
    class Agent
      include Singleton

      def initialize
        on_receive = Proc.new do |response|
          if response =~ /^#/
            _, id, response_body = response.match(/^#([^\s]+) (.+)/m).to_a

            if callbacks[id]
              callbacks[id].call(response_body)
              callbacks.delete(id)
            end
          else
            messages.push(response)
          end
        end

        api.callback = on_receive
      end

      def on_message(&callback)
        message_callbacks << callback if callback
      end

      def skype_running?
        api.running?
      end

      def name
        api.name
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

        callbacks[id] = callback
        api.send_command('#%s %s' % [id, command_str])
      end

      def send_command_sync(command_str)
        response = nil

        callback = Proc.new do |res|
          response = res
        end

        send_command_async(command_str, &callback)

        begin
          timeout(5) do
            while response.nil?
              api.run_loop(0)
              sleep 0.1
            end
          end
        rescue Timeout::Error
        end

        response
      end

      def run_forever
        loop do
          api.run_loop(0)
          consume_messages

          sleep 0.1
        end
      end

      alias send_command send_command_sync

      private

      def consume_messages
        while !messages.empty?
          message = messages.shift
          message_callbacks.each do |message_callback|
            message_callback.call(message)
          end
        end
      end

      def generate_id
        uuid.generate
      end

      def api
        @api ||= Api.new
      end

      def uuid
        @uuid ||= UUID.new
      end

      def callbacks
        @callbacks ||= {}
      end

      def messages
        @messages ||= Queue.new
      end

      def message_callbacks
        @message_callbacks ||= []
      end
    end
  end
end
