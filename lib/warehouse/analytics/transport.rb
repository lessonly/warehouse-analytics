require 'warehouse/analytics/defaults'
require 'warehouse/analytics/utils'
require 'warehouse/analytics/logging'
require 'warehouse/analytics/backoff_policy'
require 'warehouse/analytics/null_metrics'

module Warehouse
  class Analytics
    class Transport
      include Warehouse::Analytics::Utils
      include Warehouse::Analytics::Logging

      IGNORED_COLUMNS = %w[uuid uuid_ts]

      attr_reader :metrics

      def initialize(options = {})
        @event_models = options[:event_models] || {}
        @metrics = options[:metrics] || NullMetrics.new
      end

      def send(batch)
        if self.class.stub
          logger.debug "stubbed request for batch = #{batch.inspect}"
          return true
        end
        metrics.gauge('warehouse_analytics.batch.size', batch.length)
        metrics.time('warehouse_analytics.transport.latency') do
          batches_by_model = batch.group_by { |message| message['event_text'] }
          metrics.gauge('warehouse_analytics.batch.model_count', batches_by_model.length)
          batches_by_model.each do |event_name, messages|
            event_model = @event_models[event_name]

            if event_model
              column_names = event_model.column_names - IGNORED_COLUMNS

              records = messages.map do |message|
                message.slice!(*column_names)
                event_model.new(message)
              end
              result = nil
              metrics.time("warehouse_analytics.transport.import_latency") do
                result = event_model.import(column_names, records, :validate => false)
              end
              if result.failed_instances.present?
                logger.warn("Failed to insert #{result.failed_instances.length} warehouse events with name '#{event_name}'")
                metrics.increment('warehouse_analytics.transport.failures', result.failed_instances.length)
              end
            else
              logger.warn("Receieved an event (#{event_name}) without a matching key in the event_models hash")
            end
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
