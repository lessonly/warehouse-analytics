require 'warehouse/analytics/defaults'
require 'warehouse/analytics/utils'
require 'warehouse/analytics/logging'
require 'warehouse/analytics/backoff_policy'

module Warehouse
  class Analytics
    class Transport
      include Warehouse::Analytics::Utils
      include Warehouse::Analytics::Logging

      IGNORED_COLUMNS = %w[uuid uuid_ts]

      def initialize(options = {})
        @event_models = options[:event_models] || {}
      end

      def send(batch)
        logger.debug("Sending request for #{batch.length} items")

        batch.each do |message|
          event_name = message['event_text']
          event_model = @event_models[event_name]

          if event_model
            column_names = event_model.column_names - IGNORED_COLUMNS
            message.slice!(*column_names)
            record = event_model.new(message)
            result = record.class.import(column_names, [record], :validate => false)

            if result.failed_instances.present?
              logger.warn("Failed to insert warehouse event: #{result.failed_instances.first.errors.full_messages.join(',')}")
            end
          else
            logger.warn("Receieved an event (#{event_name}) without a matching key in the event_models hash")
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
