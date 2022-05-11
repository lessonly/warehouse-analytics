require 'warehouse/analytics/logging'

module Warehouse
  class Analytics
    # Handles transforming fields according to the Warehouse Spec
    #   • The warehouse transformer stringifies all properties that contain a nested array
    #   • The warehouse transformer stringifies all context fields that contain a nested array
    #   • The warehouse transformer stringifies all traits that contain a nested array
    #   • The warehouse transformer “flattens” all properties that contain a nested object
    #   • The warehouse transformer “flattens” all traits that contain a nested object
    #   • The warehouse transformer “flattens” all context fields that contain a nested object (for example, context.field.nestedA.nestedB becomes a column called context_field_nestedA_nestedB)
    # @see https://segment.com/docs/connections/storage/warehouses/schema/
    #
    # Redshift property name and event reserved word restrictions
    #   • https://segment.com/docs/connections/storage/warehouses/redshift-faq/
    #
    class Transformer
      class << self
        include Warehouse::Analytics::Logging

        VALID_VALUE_TYPES = [String, Numeric, TrueClass, FalseClass, Time, DateTime, Array, Hash]

        def transform(message)
          flattened_message = flatten({ **message })
          renamed_properties_message = rename_properties(flattened_message)
          prefix_reserved_words(renamed_properties_message)
        end

        def rename_properties(message)
          message["event_text"] = message["event"] if message["event"].present?
          message["event"] = snake_case(message["event"]) if message["event"].present?
          message["id"] = message["messageId"] if message["messageId"].present?
          message
        end

        def flatten(message)
          flatten_hash(message, true)
        end

        def prefix_reserved_words(message)
          message["event"] = prefix_redshift_reserved_words(message["event"]) if message["event"].present?
          message.transform_keys {|key| prefix_redshift_reserved_words(key) }
        end

        private

        def prefix_redshift_reserved_words(word)
          Defaults::Redshift::RESERVED_WORDS.find { |e| /#{word}/i =~ e }.present? ? "_#{word}" : word
        end

        def snake_case(word)
          # Based on underscore from rails active support
          # https://github.com/wycats/rails-api/blob/4aa40d1381fac5bc69bae6bb8e24dfb421997b40/vendor/rails/activesupport/lib/active_support/inflector/methods.rb#L38
          word.to_s
            .gsub(/::|:|\//, '_')                   # Convert all ::, :, / to _
            .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')   # Insert _ between capital letter preceding lower case letter (ignores the start of the word)
            .gsub(/([a-z])([A-Z])/,'\1_\2')         # Insert _ between lower case letter preceding a capital letter
            .tr("- ", "_")                          # Convert hyphens - and spaces to underscore
            .downcase                               # Convert all capital letters to lower case
        end

        def valid_value_type?(value)
          VALID_VALUE_TYPES.find { |valid_class| value.is_a? valid_class }
        end

        def flatten_hash(hash, top_level)
          hash.each_with_object({}) do |(k, v), h|
            if v.is_a? Hash
              key_prefix = ((top_level && k == :context) || !top_level) ? "#{k}_" : ""
              flatten_hash(v, false).map do |h_k, h_v|
                h["#{key_prefix}#{snake_case(h_k)}".to_s] = h_v
              end
            elsif v.is_a? Array
              h[k.to_s] = "[#{v.join(',')}]"
            elsif valid_value_type?(v)
              h[k.to_s] = v
            else
              logger.warn "Unexpected Data Type (#{v.class}) in flatten_hash for key (#{k})"
            end
           end
        end
      end
    end
  end
end
