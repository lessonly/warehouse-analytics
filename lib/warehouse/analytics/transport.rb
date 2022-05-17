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

        batches_by_model = batch.group_by { |message| message['event_text'] }
        batches_by_model.each do |event_name, messages|
          event_model = @event_models[event_name]

          if event_model
            column_names = event_model.column_names - IGNORED_COLUMNS

            records = messages.map do |message|
              message.slice!(*column_names)
              event_model.new(message)
            end
            result = event_model.import(column_names, records, :validate => false)
            if result.failed_instances.present?
              logger.warn("Failed to insert #{result.failed_instances.length} warehouse events with name '#{event_name}'")
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
