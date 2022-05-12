require 'warehouse/analytics/defaults'
require 'warehouse/analytics/utils'
require 'warehouse/analytics/logging'
require 'warehouse/analytics/backoff_policy'

module Warehouse
  class Analytics
    class Transport
      include Warehouse::Analytics::Utils
      include Warehouse::Analytics::Logging

      def initialize(options = {}); end

      def send(batch)
        logger.debug("Sending request for #{batch.length} items")

        batch.each do |message|
          next unless message[:event] == 'on_demand_practice_learn_more_clicked'
          message.slice!(*Tracking::OnDemandPracticeLearnMoreClicked.column_names)
          unless Tracking::OnDemandPracticeLearnMoreClicked.create(message)
            logger.warn("Failed to insert warehouse event: #{message.inspect}")
          end
        end
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
