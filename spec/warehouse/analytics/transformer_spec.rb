require 'spec_helper'

module Warehouse
  class Analytics
    describe Transformer do
      describe '#transform' do
        it 'empty returns empty' do
          expect(Transformer.transform({})).to eq({})
        end

        it 'stringifies all properties that contain a nested array' do
          message = { properties: { nested_array: ['Gang', 'is', 'all', 'here'] } }
          expect(Transformer.transform(message)).to eq({
            nested_array: '[Gang,is,all,here]'
          })
        end

        it 'stringifies all context fields that contain a nested array' do
          message = { context: { roles: ['admin', 'manager'] } }
          expect(Transformer.transform(message)).to eq({
            context_roles: '[admin,manager]'
          })
        end

        it 'stringifies all traits that contain a nested array' do
          message = { traits: { address: { street: '1129 E 16th St, Indianapolis, IN 46202'} } }
          expect(Transformer.transform(message)).to eq({
            address_street: '1129 E 16th St, Indianapolis, IN 46202'
          })
        end

        it '“flattens” all properties that contain a nested object' do
          message = {
            properties: {
              nested_object: {
                deeply_nested_object: {
                  deepest_nested_object: {
                    deepiest_nested_object: {
                      yes: "deepiest"
                    }
                  }
                }
              },
              nested_object_2: {
                mild_depth: true
              },
              shallow: "shallow"
            }
          }
          expect(Transformer.transform(message)).to eq({
            nested_object_deeply_nested_object_deepest_nested_object_deepiest_nested_object_yes: "deepiest",
            nested_object_2_mild_depth: true,
            shallow: "shallow"
          })
        end
        it '“flattens” all traits that contain a nested object' do
          message = {
            traits: {
              nested_object: {
                deeply_nested_object: {
                  deepest_nested_object: {
                    deepiest_nested_object: {
                      yes: "deepiest"
                    }
                  }
                }
              },
              nested_object_2: {
                mild_depth: true
              },
              shallow: "shallow"
            }
          }
          expect(Transformer.transform(message)).to eq({
            nested_object_deeply_nested_object_deepest_nested_object_deepiest_nested_object_yes: "deepiest",
            nested_object_2_mild_depth: true,
            shallow: "shallow"
          })
        end

        it '“flattens” all context fields that contain a nested object' do
          # (for example, context.field.nestedA.nestedB becomes a column called context_field_nestedA_nestedB)
          message = {
            context: {
              nested_object: {
                deeply_nested_object: {
                  deep: "deep"
                }
              },
              nested_object_2: {
                mild_depth: true
              },
              shallow: "shallow",
              another_object: {
                field_1: 'this is field 1',
                field_2: 'this is field 2',
                field_3: 'this is field 3'
              }
            }
          }
          expect(Transformer.transform(message)).to eq({
            context_nested_object_deeply_nested_object_deep: "deep",
            context_nested_object_2_mild_depth: true,
            context_shallow: "shallow",
            context_another_object_field_1: 'this is field 1',
            context_another_object_field_2: 'this is field 2',
            context_another_object_field_3: 'this is field 3'
          })
        end

        it 'prefixes reserved event and keys' do
          message = {
            event: Defaults::Redshift::RESERVED_WORDS[2],
            properties: Defaults::Redshift::RESERVED_WORDS.to_h { |k| [(rand 2) == 0 ? k.downcase : k.upcase, k] }
          }
          expect(Transformer.transform(message)).to eq({
            event: "_#{Defaults::Redshift::RESERVED_WORDS[2]}",
          }.merge(Defaults::Redshift::RESERVED_WORDS.to_h { |k| ["_#{k.downcase}", k] }))
        end
      end

      describe '#prefix_reserved_words' do
        it 'prefixes all redshift reserved words' do
          message = {
            event: Defaults::Redshift::RESERVED_WORDS[2],
          }.merge(Defaults::Redshift::RESERVED_WORDS.to_h { |k| [k, k] })

          expect(Transformer.prefix_reserved_words(message)).to eq({
            event: "_#{Defaults::Redshift::RESERVED_WORDS[2]}",
          }.merge(Defaults::Redshift::RESERVED_WORDS.to_h { |k| ["_#{k}", k] }))
        end
      end

    end
  end
end
