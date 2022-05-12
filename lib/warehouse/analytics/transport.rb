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

        responses = [true]

        batch.each do |message|
          next unless message['event'] == 'on_demand_practice_learn_more_clicked'
          message.slice!(*Tracking::OnDemandPracticeLearnMoreClicked.column_names)
          response = Tracking::OnDemandPracticeLearnMoreClicked.create(message)
          unless response
            logger.warn("Failed to insert warehouse event: #{message.inspect}")
          end

          responses << response
        end

        responses
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
