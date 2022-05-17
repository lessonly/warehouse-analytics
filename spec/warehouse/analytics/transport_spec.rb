require 'spec_helper'

module Warehouse
  class Analytics
    describe Transport do
      before do
        # Try and keep debug statements out of tests
        allow(subject.logger).to receive(:error)
        allow(subject.logger).to receive(:debug)
      end

      describe '#send' do
        let(:batch) { [] }
        let(:options) do
          {
            event_models: {
              :on_demand_practice_learn_more_clicked => Tracking::Warehouse::OnDemandPracticeLearnMoreClicked
            }
          }
        end

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
          it 'successfully saves a record to the database for Tracking::Warehouse::OnDemandPracticeLearnMoreClicked events' do
            batch = [{ 'event' => 'on_demand_practice_learn_more_clicked', 'not_a_column' => "I'm not a column!" }]

            expect(subject.logger).to receive(:debug)
            expect(subject.logger).not_to receive(:warn)
            expect(Tracking::Warehouse::OnDemandPracticeLearnMoreClicked).to receive(:new)
              .with({ 'event' => 'on_demand_practice_learn_more_clicked' })
              .and_call_original
            expect(Tracking::Warehouse::OnDemandPracticeLearnMoreClicked).to receive(:import)
              .with([an_instance_of(Tracking::Warehouse::OnDemandPracticeLearnMoreClicked)])
              .and_return(double(failed_instances: []))
            described_class.new(options).send(batch)
          end

          it 'does not save a record to the database for any other event' do
            batch = [{ 'event' => 'test_event' }]

            expect(subject.logger).to receive(:debug)
            expect(Tracking::Warehouse::OnDemandPracticeLearnMoreClicked).to_not receive(:new)
            described_class.new(options).send(batch)
          end
        end
      end
    end
  end
end
