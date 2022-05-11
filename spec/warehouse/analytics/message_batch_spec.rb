require 'spec_helper'

module Warehouse
  class Analytics
    describe MessageBatch do
      subject { described_class.new(100) }

      describe '#<<' do
        it 'appends messages' do
          subject << { 'a' => 'b' }
          expect(subject.length).to eq(1)
        end
      end

      describe '#full?' do
        it 'returns true once item count is exceeded' do
          99.times { subject << { a: 'b' } }
          expect(subject.full?).to be(false)

          subject << { a: 'b' }
          expect(subject.full?).to be(true)
        end
      end
    end
  end
end
