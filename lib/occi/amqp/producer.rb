require "amqp"

module Occi
  module Amqp
    class Producer

      attr_reader :reply_queue_name

      def initialize(channel, exchange, reply_queue_name)
        @channel          = channel
        @exchange         = exchange
        @reply_queue_name = reply_queue_name
      end

      def send(message)
        @exchange.publish(message.payload, message.options)
      end
    end
  end
end