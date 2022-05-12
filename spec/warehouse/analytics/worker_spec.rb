require 'spec_helper'

module Warehouse
  class Analytics
    describe Worker do
      before do
        Warehouse::Analytics::Transport.stub = true
      end

      describe '#init' do
        it 'accepts string keys' do
          queue = Queue.new
          worker = Warehouse::Analytics::Worker.new(queue, 'batch_size' => 100)
          batch = worker.instance_variable_get(:@batch)
          expect(batch.instance_variable_get(:@max_message_count)).to eq(100)
        end
      end

      describe '#run' do
        it 'does not error if the request fails' do
          expect do
            Warehouse::Analytics::Transport
              .any_instance
              .stub(:send)
              .and_return([true, false])

            queue = Queue.new
            queue << {}
            worker = Warehouse::Analytics::Worker.new(queue)
            worker.run

            expect(queue).to be_empty

            Warehouse::Analytics::Transport.any_instance.unstub(:send)
          end.to_not raise_error
        end

        it 'returns true if there is a current batch' do
          Warehouse::Analytics::Transport
            .any_instance
            .stub(:send) {
              sleep(0.2)
              [true, true]
            }

          queue = Queue.new
          queue << Requested::TRACK
          worker = Warehouse::Analytics::Worker.new(queue)

          worker_thread = Thread.new { worker.run }
          eventually { expect(worker.is_requesting?).to eq(true) }

          worker_thread.join
          expect(worker.is_requesting?).to eq(false)

          Warehouse::Analytics::Transport.any_instance.unstub(:send)
        end
      end
    end
  end
end
