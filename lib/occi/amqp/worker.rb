require "amqp"

module Occi
  module Amqp
    class Worker

      def initialize(channel, consumer, producer, queue_name = AMQ::Protocol::EMPTY_STRING)
        @queue_name = queue_name

        @channel    = channel
        @channel.on_error(&method(:handle_channel_exception))

        @consumer   = consumer
        @producer   = producer
      end

      def start
        @queue = @channel.queue(@queue_name, :exclusive => true, :auto_delete => true)
        @queue.subscribe(&@consumer.method(:handle_message))
      end

      def handle_channel_exception(channel, channel_close)
        Occi::Log.error "OCCI/AMQP: Channel-level exception [ code = #{channel_close.reply_code}, message = #{channel_close.reply_text} ]"
      end

      def next_message_id
        @message_id  = 0 if @message_id.nil?
        @message_id += 1
        @message_id.to_s;
      end

      def waiting_for_response(message_id = '')
        return if @response_waiting.nil?

        if message_id.size > 0
          sleep(0.1) while !@response_waiting[message_id].nil?
        else
          sleep(0.1) while size(@response_waiting) > 0
        end
      end

      def send(message, wait = false)
        message_id = message.options["message_id"]

        @producer.send(message)

        @response_waiting             = Hash.new if @response_waiting.nil?
        @response_waiting[message_id] = {:message => message}

        waiting_for_response(message_id) if wait

        message_id
      end

      def set_response_message(metadata, payload)
        correlation_id = metadata.correlation_id

        unless correlation_id.size > 0
          raise "Message has no correlation_id (message_id)"
        end

        @response_messages = Hash.new                             if @response_messages.nil?
        raise "Double Response Message ID: (#{ correlation_id })" if @response_messages.has_key?(correlation_id)
        message = @response_waiting[correlation_id][:message]
        #save responses message
        @response_messages[correlation_id] = {:payload => payload, :metadata => metadata, :type => message.options[:type]}

        #delete message_id from waiting stack
        @response_waiting.delete(correlation_id) unless @response_waiting.nil?
      end

      def get_response_message(message_id)
        @response_messages[message_id]
      end

    end
  end
end