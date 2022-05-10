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

        def transform(message)
          normalized_event = normalize(message)
          flattened_message = flatten(normalized_event)
          prefix_reserved_words(flattened_message)
        end

        def normalize(message)
          message[:event_text] = message[:event] if message[:event].present?
          message[:event] = snake_case(message[:event]) if message[:event].present?
          message
        end

        def flatten(message)
          flatten_hash(message, true)
        end

        def prefix_reserved_words(message)
          message[:event] = prefix_redshift_reserved_words(message[:event]) if message[:event].present?
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
            .gsub(/::/, '_')                        # Convert :: Namespace Colons to _
            .gsub(/:/, '_')                         # Convert single : colon to _
            .gsub(/\//, '_')                        # Convert forward slash / to _
            .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')   # Insert _ between capital letter preceding lower case letter (ignores the start of the word)
            .gsub(/([a-z])([A-Z])/,'\1_\2')         # Insert _ between lower case letter preceding a capital letter
            .tr("- ", "_")                          # Convert hyphens - and spaces to underscore
            .downcase                               # Convert all capital letters to lower case
        end

        def flatten_hash(hash, top_level)
          hash.each_with_object({}) do |(k, v), h|
            if v.is_a? Hash
              key_prefix = ((top_level && k == :context) || !top_level) ? "#{k}_" : ""
              flatten_hash(v, false).map do |h_k, h_v|
                h["#{key_prefix}#{snake_case(h_k)}".to_sym] = h_v
              end
            elsif v.is_a? Array
              h[k] = "[#{v.join(',')}]"
            else
              h[k] = v
            end
           end
        end
      end
    end
  end
end
