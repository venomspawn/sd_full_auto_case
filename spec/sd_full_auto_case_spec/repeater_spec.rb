# frozen_string_literal: true

# Файл тестирования модуля `SDFullAutoCase::Repeater`, предоставляющего
# функцию `repeat` для отложенной отправки запросов

RSpec.describe SDFullAutoCase::Repeater do
  describe 'the module' do
    subject { described_class }

    it { is_expected.to respond_to(:repeat) }
  end

  describe '.repeat' do
    include described_class::SpecHelper

    before { SDFullAutoCase.on_load }

    after { SDFullAutoCase.on_unload }

    subject { described_class.repeat }

    let(:ereq_max_count) { repeat_namespace::MAX_EXCEPTIONS_COUNT }
    let(:repeat_namespace) { SDFullAutoCase::Request::Repeat }
    let!(:repeat_case) { create_case(0) }
    let!(:too_many_case) { create_case(ereq_max_count + 1) }
    let!(:just_a_case) { FactoryBot.create(:case, type: type) }
    let(:type) { 'sd_full_auto_case' }
    let!(:attr) { FactoryBot.create(:case_attribute, **args) }
    let(:args) { { case_id: just_a_case.id, name: 'state', value: 'closed' } }

    it 'should select cases with `error` state' do
      expect(SDFullAutoCase::Request::Repeat)
        .to receive(:repeat)
        .with(repeat_case.id, instance_of(Hash))
        .and_call_original
      expect(SDFullAutoCase::Request::Repeat)
        .to receive(:repeat)
        .with(too_many_case.id, instance_of(Hash))
        .and_call_original
      subject
    end

    it 'should schedule resends of the requests' do
      expect(SDFullAutoCase::Scheduler).to receive(:in).once
      subject
    end
  end
end
