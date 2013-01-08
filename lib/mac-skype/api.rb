module Mac
  module Skype
    class Api
      attr_accessor :callback, :attach

      def initialize
        @attach = 0
        init
      end

      def debug?
        !ENV['DEBUG'].nil?
      end

      def receive_event(response)
        if callback
          callback.call(response)
        end
      end
    end
  end
end
