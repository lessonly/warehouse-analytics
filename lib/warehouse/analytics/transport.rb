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
          next unless message['event'] == 'on_demand_practice_learn_more_clicked'
          message.slice!(*Tracking::Warehouse::OnDemandPracticeLearnMoreClicked.column_names)
          record = Tracking::OnDemandPracticeLearnMoreClicked.new(message)
          result = record.class.import([record])
          if result.failed_instances.present?
            logger.warn("Failed to insert warehouse event: #{result.failed_instances.first.errors.full_messages.join(',')}")
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
