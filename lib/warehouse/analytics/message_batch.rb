require 'forwardable'
require 'warehouse/analytics/logging'

module Warehouse
  class Analytics
    # A batch of `Message`s to be sent to the API
    class MessageBatch
      extend Forwardable
      include Warehouse::Analytics::Logging
      include Warehouse::Analytics::Defaults::MessageBatch

      def initialize(max_message_count)
        @messages = []
        @max_message_count = max_message_count
      end

      def <<(message)
        @messages << Warehouse::Analytics::Transformer.transform(message)
      end

      def full?
        item_count_exhausted?
      end

      def clear
        @messages.clear
      end

      def_delegators :@messages, :empty?
      def_delegators :@messages, :length
      def_delegators :@messages, :each

      private

      def item_count_exhausted?
        @messages.length >= @max_message_count
      end
    end
  end
end
