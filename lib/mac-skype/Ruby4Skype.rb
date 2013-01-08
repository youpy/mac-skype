require 'skype'

module Skype
  class << self
    def init
      init_os(Skype::OS::MacNative, "")
      @notify = Hash.new
      init_notifier
    end
  end

  module OS
    class MacNative < Skype::OS::Abstruct
      def initialize client_application_name = nil
        @attached = false
        @debug = false
        @agent = Mac::Skype::Agent.instance
      end

      attr_reader :name, :attached, :response, :debug
      attr_writer :attached

      def start_messageloop
        raise 'not impremented yet. use messageloop().'
      end

      def messageloop
        @agent.run_forever
      end

      def attach
        unless attached?
          @agent.connect
        end
      end

      def attach_wait
        attach
        sleep 0.1 until attached?
        @agent.send_command('PROTOCOL 9999')
      end

      def attached?
        @agent.connected?
      end

      def dettach
        self.attached = false
        @agent.disconnect
      end

      def skype_running?
        @agent.running?
      end

      def invoke_callback cmd, cb = Proc.new
        res = invoke_block cmd
        cb.call res
      end

      def invoke_block cmd
        p ">#{cmd}" if @debug

        @agent.send_command(cmd)
      end

      def set_notify_selector(block = Proc.new)
        @agent.on_message(&block)
      end

      def close
        dettach if attached?
      end
    end
  end
end
