require 'warehouse/analytics/defaults'
require 'warehouse/analytics/message_batch'
require 'warehouse/analytics/transport'
require 'warehouse/analytics/utils'

module Warehouse
  class Analytics
    class Worker
      include Warehouse::Analytics::Utils
      include Warehouse::Analytics::Defaults
      include Warehouse::Analytics::Logging

      # public: Creates a new worker
      #
      # The worker continuously takes messages off the queue
      # and makes requests to the warehouse.io api
      #
      # queue   - Queue synchronized between client and worker
      # options - Hash of worker options
      #           batch_size - Fixnum of how many items to send in a batch
      #           on_error   - Proc of what to do on an error
      #
      def initialize(queue, options = {})
        symbolize_keys! options
        @queue = queue
        @on_error = options[:on_error] || proc { |status, error| }
        batch_size = options[:batch_size] || Defaults::MessageBatch::MAX_SIZE
        @batch = MessageBatch.new(batch_size)
        @lock = Mutex.new
        @transport = Transport.new(options)
      end

      # public: Continuously runs the loop to check for new events
      #
      def run
        until Thread.current[:should_exit]
          return if @queue.empty?

          @lock.synchronize do
            consume_message_from_queue! until @batch.full? || @queue.empty?
          end

          responses = @transport.send @batch
          @on_error.call(nil, 'Failed to insert a warehouse event') if responses.include?(false)

          @lock.synchronize { @batch.clear }
        end
      end

      # public: Check whether we have outstanding requests.
      #
      def is_requesting?
        @lock.synchronize { !@batch.empty? }
      end

      private

      def consume_message_from_queue!
        @batch << @queue.pop
      end
    end
  end
end
