module Occi
  module Amqp
    class Message
      attr_accessor :payload, :options

      def initialize()
        @payload = ""
        @options = {
            :routing_key  => '',
            :content_type => "text/plain",
            :type         => "",
            :reply_to     => "",  #queue for response from the rOCCI
            :message_id   => "",  #Identifier for message so that the client can match the answer from the rOCCI
            :headers => {
                :accept    => @media_type,
                :path_info => "",
                :auth => {
                    :type     => "basic",
                    :username => "user",
                    :password => "mypass",
                },
            }
        }
      end

      def method_missing(name, *args, &block)
        if @attributes && args.empty? && block.nil? && @attributes.has_key?(name)
          @options[name]
        else
          self.send(name, *args, &block)
        end
      end
    end
  end
end