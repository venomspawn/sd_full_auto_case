# frozen_string_literal: true

RSpec.describe SDFullAutoCase::Base::MessageDrivenFSA::OutputFilesExtractor do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:extract) }
  end

  describe '.extract' do
    include described_class::SpecHelper

    subject { described_class.extract(case_id, attachments) }

    let(:c4s3)        { create_case('processing') }
    let(:case_id)     { c4s3.id }
    let(:attachments) { [{ fs_id: '1' }, { fs_id: '2' }] }

    it 'should create document records and associate\'em with the case' do
      expect { subject }.to change { c4s3.documents_dataset.count }.by(2)
    end

    it 'should create file records' do
      expect { subject }.to change { files_count }.by(2)
    end

    context 'when attachments have `nil` as an element' do
      let(:attachments) { [{ fs_id: '1' }, nil, { fs_id: '2' }, nil] }

      it 'should create document records and associate\'em with the case' do
        expect { subject }.to change { c4s3.documents_dataset.count }.by(2)
      end
    end
  end
end
