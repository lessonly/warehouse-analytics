require 'spec_helper'

module Warehouse
  class Analytics
    describe Transport do
      before do
        # Try and keep debug statements out of tests
        allow(subject.logger).to receive(:error)
        allow(subject.logger).to receive(:debug)
      end

      describe '#initialize' do
      end

      describe '#send' do
        let(:batch) { [] }

        context 'with a stub' do
          before do
            allow(described_class).to receive(:stub) { true }
          end

          it 'does not receieve a debug statement on error' do
            expect(subject.logger).not_to receive(:warn)
            subject.send(batch)
          end
        end

        context 'a real request' do
          # TODO: Write some tests
        end
      end
    end
  end
end
