require 'spec_helper'

module Warehouse
  class Analytics
    describe Transformer do
      describe '#transform' do
        it 'empty returns empty' do
          expect(Transformer.transform({})).to eq({})
        end

        it 'stringifies all properties that contain a nested array' do
          message = { properties: { nested_array: %w[Gang is all here] } }
          expect(Transformer.transform(message)).to eq({
            nested_array: '[Gang,is,all,here]'
          }.stringify_keys)
        end

        it 'stringifies all context fields that contain a nested array' do
          message = { context: { roles: %w[admin manager] } }
          expect(Transformer.transform(message)).to eq({
            context_roles: '[admin,manager]'
          }.stringify_keys)
        end

        it 'stringifies all traits that contain a nested array' do
          message = { traits: { address: { street: '1129 E 16th St, Indianapolis, IN 46202' } } }
          expect(Transformer.transform(message)).to eq({
            address_street: '1129 E 16th St, Indianapolis, IN 46202'
          }.stringify_keys)
        end

        it '“flattens” all properties that contain a nested object' do
          message = {
            properties: {
              nested_object: {
                deeply_nested_object: {
                  deepest_nested_object: {
                    deepiest_nested_object: {
                      yes: 'deepiest'
                    }
                  }
                }
              },
              nested_object_2: {
                mild_depth: true
              },
              shallow: nil
            }
          }
          expect(Transformer.transform(message)).to eq({
            nested_object_deeply_nested_object_deepest_nested_object_deepiest_nested_object_yes: 'deepiest',
            nested_object_2_mild_depth: true,
            shallow: nil
          }.stringify_keys)
        end

        it '“flattens” all traits that contain a nested object' do
          message = {
            traits: {
              nested_object: {
                deeply_nested_object: {
                  deepest_nested_object: {
                    deepiest_nested_object: {
                      yes: 'deepiest'
                    }
                  }
                }
              },
              nested_object_2: {
                mild_depth: true
              },
              shallow: 'shallow'
            }
          }
          expect(Transformer.transform(message)).to eq({
            nested_object_deeply_nested_object_deepest_nested_object_deepiest_nested_object_yes: 'deepiest',
            nested_object_2_mild_depth: true,
            shallow: 'shallow'
          }.stringify_keys)
        end

        it '“flattens” all context fields that contain a nested object' do
          # (for example, context.field.nestedA.nestedB becomes a column called context_field_nestedA_nestedB)
          message = {
            context: {
              nested_object: {
                deeply_nested_object: {
                  deep: 'deep'
                }
              },
              nested_object_2: {
                mild_depth: true
              },
              shallow: 'shallow',
              another_object: {
                field_1: 'this is field 1',
                field_2: 'this is field 2',
                field_3: 'this is field 3'
              }
            }
          }
          expect(Transformer.transform(message)).to eq({
            context_nested_object_deeply_nested_object_deep: 'deep',
            context_nested_object_2_mild_depth: true,
            context_shallow: 'shallow',
            context_another_object_field_1: 'this is field 1',
            context_another_object_field_2: 'this is field 2',
            context_another_object_field_3: 'this is field 3'
          }.stringify_keys)
        end

        it 'snake_cases event name with a space, :, and /' do
          message = {
            event: 'Test: Event/GreatName'
          }
          expect(Transformer.transform(message)).to eq({
            event_text: 'Test: Event/GreatName',
            event: 'test_event_great_name'
          }.stringify_keys)
        end

        it 'snake_cases event name with :: namespace and spaces' do
          message = {
            event: 'Test::Event PascalCase'
          }
          expect(Transformer.transform(message)).to eq({
            event_text: 'Test::Event PascalCase',
            event: 'test_event_pascal_case'
          }.stringify_keys)
        end

        it 'snake_cases all keys' do
          message = {
            properties: {
              nestedObject: {
                NotSnakeCase: 'Please'
              }
            },
            context: {
              NotSnakeCase: 'At all'
            },
            traits: {
              camelCase: 'oops'
            }
          }
          expect(Transformer.transform(message)).to eq({
            nested_object_not_snake_case: 'Please',
            context_not_snake_case: 'At all',
            camel_case: 'oops'
          }.stringify_keys)
        end

        it 'ignores unexpected value data type' do
          message = {
            properties: {
              unknown_type: RuntimeError.new("We don't handle error types!")
            }
          }
          expect(Transformer.transform(message)).to eq({})
        end

        it 'truncates long strings to 512 characters' do
          message = {
            properties: {
              string: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel euismod velit. Ut placerat urna sit amet euismod facilisis. Cras efficitur nisi suscipit, auctor ligula sed, dignissim augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Vivamus laoreet nisi sit amet feugiat faucibus. Aliquam commodo tellus quam, a egestas metus sagittis nec. Suspendisse nec quam non nibh condimentum hendrerit quis non metus. Phasellus vitae mattis nisi. Maecenas et condimentum felis, quis fringilla velit. Fusce sagittis condimentum vulputate. Sed lectus tellus, feugiat ut ligula id, luctus consectetur purus. Duis quis libero id augue fringilla egestas ac at felis. Phasellus quis molestie libero. Integer et elementum ligula, et finibus leo. Donec vitae tellus nec massa commodo rutrum in eget est.'
            }
          }
          expect(Transformer.transform(message)).to eq({
            string: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel euismod velit. Ut placerat urna sit amet euismod facilisis. Cras efficitur nisi suscipit, auctor ligula sed, dignissim augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Vivamus laoreet nisi sit amet feugiat faucibus. Aliquam commodo tellus quam, a egestas metus sagittis nec. Suspendisse nec quam non nibh condimentum hendrerit quis non metus. Phasellus vitae mattis nisi. Maecenas et condimentum fe...'
          }.stringify_keys)
        end

        it 'prefixes reserved event and keys' do
          message = {
            event: 'ALL',
            properties: Defaults::Redshift::RESERVED_WORDS.to_h { |k| [(rand 2) == 0 ? k.downcase : k.upcase, true] }
          }
          expect(Transformer.transform(message)).to eq({
            event: '_all',
            event_text: 'ALL'
          }.merge(Defaults::Redshift::RESERVED_WORDS.transform_keys { |k| "_#{k.downcase}" }).stringify_keys)
        end
      end

      describe '#prefix_reserved_words' do
        it 'prefixes all redshift reserved words' do
          message = {
            'event' => 'ALL'
          }.merge(Defaults::Redshift::RESERVED_WORDS.to_h { |k| [k, true] })

          expect(Transformer.prefix_reserved_words(message)).to eq({
            'event' => '_ALL'
          }.merge(Defaults::Redshift::RESERVED_WORDS.transform_keys { |k| "_#{k}" }))
        end
      end
    end
  end
end
