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

        it 'executes the error handler if the request is invalid' do
          Warehouse::Analytics::Transport
            .any_instance
            .stub(:send)
            .and_return([true, false])

          status = error = nil
          on_error = proc do |yielded_status, yielded_error|
            sleep 0.2 # Make this take longer than thread spin-up (below)
            status, error = yielded_status, yielded_error
          end

          queue = Queue.new
          queue << {}
          worker = described_class.new(queue, :on_error => on_error)

          # This is to ensure that Client
          # flush doesn't finish before calling
          # the error handler.
          Thread.new { worker.run }
          sleep 0.1 # First give thread time to spin-up.
          sleep 0.01 while worker.is_requesting?

          Warehouse::Analytics::Transport.any_instance.unstub(:send)

          expect(queue).to be_empty
          expect(error).to eq('Failed to insert a warehouse event')
        end

        it 'does not call on_error if the request is good' do
          on_error = proc do |status, error|
            puts "#{status}, #{error}"
          end

          expect(on_error).to_not receive(:call)

          queue = Queue.new
          queue << Requested::TRACK
          worker = described_class.new(queue, :on_error => on_error)
          worker.run

          expect(queue).to be_empty
        end
      end

      describe '#is_requesting?' do
        it 'does not return true if there isn\'t a current batch' do
          queue = Queue.new
          worker = Warehouse::Analytics::Worker.new(queue)

          expect(worker.is_requesting?).to eq(false)
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
