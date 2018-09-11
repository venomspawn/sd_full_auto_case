# frozen_string_literal: true

# Файл тестирования модуля `SDFullAutoCase::Scheduler`, предоставляющего
# функции для работы с планировщиком событий

RSpec.describe SDFullAutoCase::Scheduler do
  describe 'the module' do
    subject { described_class }

    it { is_expected.to respond_to(:launch, :stop, :in, :cron) }
  end

  describe '.launch' do
    subject { described_class.launch }

    it 'should create scheduler' do
      expect { subject }
        .to change { described_class.instance_variable_get('@scheduler') }
    end

    it 'should launch the scheduler' do
      subject
      expect(described_class.instance_variable_get('@scheduler').up?)
        .to be_truthy
    end

    context 'when there already is a scheduler' do
      before { described_class.launch }

      it 'should create new one' do
        expect { subject }
          .to change { described_class.instance_variable_get('@scheduler') }
      end
    end
  end

  describe '.stop' do
    before { described_class.launch }

    subject { described_class.stop }

    it 'should remove scheduler' do
      expect { subject }
        .to change { described_class.instance_variable_get('@scheduler') }
        .to nil
    end

    context 'when there is a scheduler running' do
      let!(:scheduler) { described_class.instance_variable_get('@scheduler') }

      it 'should stop it' do
        expect { subject }.to change { scheduler.up? }.from(true).to(false)
      end
    end
  end

  describe '.in' do
    before { described_class.launch }
    after  { described_class.stop }

    subject { described_class.in(time) {} }

    let(:time) { '1s' }
    let!(:scheduler) { described_class.instance_variable_get('@scheduler') }

    it 'should add new job to schedule in provided time' do
      expect(scheduler).to receive(:in)
      subject
    end
  end

  describe '.cron' do
    before { described_class.launch }
    after  { described_class.stop }

    subject { described_class.cron(cron) {} }

    let(:cron) { '* * * * *' }
    let!(:scheduler) { described_class.instance_variable_get('@scheduler') }

    it 'should add new job to schedule by provided cron-line' do
      expect(scheduler).to receive(:cron)
      subject
    end
  end
end
