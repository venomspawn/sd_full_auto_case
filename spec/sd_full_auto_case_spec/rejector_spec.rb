# frozen_string_literal: true

# Тесты модуля `SDFullAutoCase::Rejector`

RSpec.describe SDFullAutoCase::Rejector do
  describe 'the module' do
    subject { described_class }

    it { is_expected.to respond_to(:reject) }
  end

  describe '.reject' do
    include described_class::SpecHelper

    subject { described_class.reject }

    let(:expired_args) { { planned_rejecting_date: yesterday.to_s } }
    let(:yesterday) { Date.today - 1 }
    let!(:rotten_case) { create_case('issuance', **rotten_args) }
    let!(:another_rotten_case) { create_case('issuance', **rotten_args) }
    let(:rotten_args) { expired_args }
    let!(:marked_case) { create_case('issuance', **marked_args) }
    let!(:another_marked_case) { create_case('issuance', **marked_args) }
    let(:marked_args) { { close_on_reject: mark, **expired_args } }
    let(:mark) { SDFullAutoCase::RespondToMessage::CLOSE_ON_REJECT_MARK }
    let!(:fresh_case) { create_case('issuance', **fresh_args) }
    let(:fresh_args) { { planned_rejecting_date: tomorrow.to_s } }
    let(:tomorrow) { Date.today + 1 }
    let!(:other_case) { create_case('processing', {}) }

    context 'when there are cases with outdated result' do
      context 'when the cases are without close on reject mark' do
        it 'should change state of all of the cases to `rejecting`' do
          subject
          expect(case_state(rotten_case)).to be == 'rejecting'
          expect(case_state(another_rotten_case)).to be == 'rejecting'
        end

        it 'should set `rejecting_date` attribute of all of the cases' do
          subject
          expect(case_rejecting_date(rotten_case))
            .to be_within(1).of(Time.now)
          expect(case_rejecting_date(another_rotten_case))
            .to be_within(1).of(Time.now)
        end
      end

      context 'when the cases are with close on reject mark' do
        it 'should change state of all of the cases to `closed`' do
          subject
          expect(case_state(marked_case)).to be == 'closed'
          expect(case_state(another_marked_case)).to be == 'closed'
        end

        it 'should set `closed_date` attribute of all of the cases' do
          subject
          expect(case_closed_date(marked_case))
            .to be_within(1).of(Time.now)
          expect(case_closed_date(another_marked_case))
            .to be_within(1).of(Time.now)
        end
      end
    end

    context 'when there are cases with non-outdated result' do
      it 'shouldn\'t touch\'em' do
        subject
        expect(case_state(fresh_case)).to be == 'issuance'
        expect(case_rejecting_date(fresh_case)).to be_nil
      end
    end

    context 'when there are cases in non-issuance state' do
      it 'shouldn\'t touch\'em' do
        subject
        expect(case_state(other_case)).to be == 'processing'
        expect(case_rejecting_date(other_case)).to be_nil
      end
    end
  end
end
