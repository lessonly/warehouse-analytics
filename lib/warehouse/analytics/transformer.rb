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
          flattend_message = flatten(message)
          prefix_reserved_words(flattend_message)
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

        def flatten_hash(hash, top_level)
          hash.each_with_object({}) do |(k, v), h|
            if v.is_a? Hash
              key_prefix = ((top_level && k == :context) || !top_level) ? "#{k}_" : ""
              flatten_hash(v, false).map do |h_k, h_v|
                h["#{key_prefix}#{h_k.downcase}".to_sym] = h_v
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
