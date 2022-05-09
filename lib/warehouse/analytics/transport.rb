require 'warehouse/analytics/defaults'
require 'warehouse/analytics/utils'
require 'warehouse/analytics/logging'
require 'warehouse/analytics/backoff_policy'

module Warehouse
  class Analytics
    class Transport
      include Warehouse::Analytics::Utils
      include Warehouse::Analytics::Logging

      def initialize(options = {})
        @retries = options[:retries] || RETRIES
        @backoff_policy =
          options[:backoff_policy] || Warehouse::Analytics::BackoffPolicy.new

      end

      def send(batch)
        logger.debug("Sending request for #{batch.length} items")

      end

      class << self
        attr_writer :stub

        def stub
          @stub || ENV['STUB']
        end
      end
    end
  end
end
