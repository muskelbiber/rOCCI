require "amqp"

module Occi
  module Amqp
    class Consumer

      def handle_message(metadata, payload)
        log("info", __LINE__, "Received a message: #{payload}, content_type = #{metadata.content_type}")
      end
    end
  end
end