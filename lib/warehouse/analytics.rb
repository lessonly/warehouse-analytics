require 'warehouse/analytics/version'
require 'warehouse/analytics/defaults'
require 'warehouse/analytics/utils'
require 'warehouse/analytics/field_parser'
require 'warehouse/analytics/client'
require 'warehouse/analytics/worker'
require 'warehouse/analytics/transformer'
require 'warehouse/analytics/transport'
require 'warehouse/analytics/logging'
require 'warehouse/analytics/test_queue'

module Warehouse
  class Analytics
    # Initializes a new instance of {Warehouse::Analytics::Client}, to which all
    # method calls are proxied.
    #
    # @param options includes options that are passed down to
    #   {Warehouse::Analytics::Client#initialize}
    # @option options [Boolean] :stub (false) If true, requests don't hit the
    #   server and are stubbed to be successful.
    def initialize(options = {})
      Transport.stub = options[:stub] if options.has_key?(:stub)
      @client = Warehouse::Analytics::Client.new options
    end

    def method_missing(message, *args, &block)
      if @client.respond_to? message
        @client.send message, *args, &block
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @client.respond_to?(method_name) || super
    end

    include Logging
  end
end
