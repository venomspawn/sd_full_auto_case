# frozen_string_literal: true

# Файл тестирования модуля `SDFullAutoCase`, предоставляющего обработчики
# событий бизнес-логики услуги социальной защиты

RSpec.shared_examples 'an attributes setter' do |names|
  names.each do |name|
    context "when attribute `#{name}` is specified in parameters" do
      let(:params) { { name => value } }
      let(:value) { create(:string) }

      it 'should set the attribute' do
        expect { subject }
          .to change { case_attributes(c4s3.id)[name] }
          .to(value)
      end
    end

    context "when attribute `#{name}` isn\'t specified in parameters" do
      let(:params) { {} }

      it 'shouldn\'t change the attribute' do
        expect { subject }.not_to change { case_attributes(c4s3.id)[name] }
      end
    end
  end
end

RSpec.shared_examples 'an attributes cleaner' do |names|
  names.each do |name|
    it "should set `#{name}` to `nil`" do
      subject
      expect(case_attributes(c4s3.id)[name]).to be_nil
    end
  end
end

RSpec.describe SDFullAutoCase do
  describe 'the module' do
    subject { described_class }

    methods = %i[
      change_state_to
      on_case_creation
      on_load
      on_responding_stomp_message
      on_unload
    ]
    it { is_expected.to respond_to(*methods) }
  end

  describe '.change_state_to' do
    subject { described_class.change_state_to(c4s3, state, params) }

    context 'when `case` argument is not of `CaseCore::Models::Case` type' do
      let(:c4s3) { 'not of `CaseCore::Models::Case` type' }
      let(:state) { 'pending' }
      let(:params) { {} }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when case type is wrong' do
      let(:c4s3) { create(:case, type: :wrong) }
      let(:state) { 'pending' }
      let(:params) { {} }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case state is absent' do
      let(:c4s3) { create(:case, type: 'sd_full_auto_case') }
      let(:state) { 'pending' }
      let(:params) { {} }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `params` argument is not of `NilClass` nor of `Hash` type' do
      let(:c4s3) { create(:case, type: 'sd_full_auto_case') }
      let!(:case_attributes) { create(:case_attributes, **traits) }
      let(:traits) { { case_id: c4s3.id, state: 'packaging' } }
      let(:state) { 'pending' }
      let(:params) { 'not of `NilClass` nor of `Hash` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when case state transition isn\'t supported' do
      let(:c4s3) { create(:case, type: 'sd_full_auto_case') }
      let!(:case_attributes) { create(:case_attributes, **traits) }
      let(:traits) { { case_id: c4s3.id, state: 'packaging' } }
      let(:state) { 'a state' }
      let(:params) { {} }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case state is switching from `packaging` to `pending`' do
      include SDFullAutoCase::ChangeStateTo::PackagingPendingSpecHelper

      let(:c4s3) { create_case('packaging') }
      let(:params) { {} }
      let(:office_id) { create(:string) }
      let(:state) { 'pending' }

      it 'should set case state to `pending`' do
        expect { subject }.to change { case_state(c4s3) }.to('pending')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:pending])
      end

      it 'should set `pending_register_sending_date` to current time' do
        subject
        expect(case_pending_register_sending_date(c4s3))
          .to be_within(1)
          .of(Time.now)
      end

      it 'should set `planned_finish_date` to `planned_sending_date`' do
        subject
        expect(case_attributes(c4s3)[:planned_finish_date])
          .to be == case_attributes(c4s3)[:planned_sending_date]
      end

      attributes = %i[
        pending_register_institution_name
        pending_register_institution_office_building
        pending_register_institution_office_city
        pending_register_institution_office_country_code
        pending_register_institution_office_country_name
        pending_register_institution_office_district
        pending_register_institution_office_house
        pending_register_institution_office_index
        pending_register_institution_office_region_code
        pending_register_institution_office_region_name
        pending_register_institution_office_room
        pending_register_institution_office_settlement
        pending_register_institution_office_street
        pending_register_number
        pending_register_operator_id
        pending_register_operator_middle_name
        pending_register_operator_name
        pending_register_operator_position
        pending_register_operator_surname
      ]
      it_should_behave_like 'an attributes setter', attributes
    end

    context 'when case state is switching from `rejecting` to `pending`' do
      include SDFullAutoCase::ChangeStateTo::RejectingPendingSpecHelper

      let(:c4s3) { create_case('rejecting') }
      let(:params) { {} }
      let(:state) { 'pending' }

      it 'should set case state to `pending`' do
        expect { subject }.to change { case_state(c4s3) }.to('pending')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:pending])
      end

      it 'should set `pending_rejecting_register_sending_date` attribute' do
        subject
        expect(case_pending_rejecting_register_sending_date(c4s3))
          .to be_within(1)
          .of(Time.now)
      end

      it 'should set `planned_finish_date` properly' do
        subject
        expect(case_attributes(c4s3)[:planned_finish_date])
          .to be == case_attributes(c4s3)[:planned_rejecting_finish_date]
      end

      attributes = %i[
        pending_rejecting_register_institution_name
        pending_rejecting_register_institution_office_building
        pending_rejecting_register_institution_office_city
        pending_rejecting_register_institution_office_country_code
        pending_rejecting_register_institution_office_country_name
        pending_rejecting_register_institution_office_district
        pending_rejecting_register_institution_office_house
        pending_rejecting_register_institution_office_index
        pending_rejecting_register_institution_office_region_code
        pending_rejecting_register_institution_office_region_name
        pending_rejecting_register_institution_office_room
        pending_rejecting_register_institution_office_settlement
        pending_rejecting_register_institution_office_street
        pending_rejecting_register_number
        pending_rejecting_register_operator_id
        pending_rejecting_register_operator_middle_name
        pending_rejecting_register_operator_name
        pending_rejecting_register_operator_position
        pending_rejecting_register_operator_surname
      ]
      it_should_behave_like 'an attributes setter', attributes
    end

    context 'when case state is switching from `pending` to `packaging`' do
      include SDFullAutoCase::ChangeStateTo::PendingPackagingSpecHelper

      let(:c4s3) { create_case(:pending, rejecting_date) }
      let(:rejecting_date) { nil }
      let(:params) { {} }
      let(:state) { 'packaging' }

      it 'should set case state to `packaging`' do
        expect { subject }.to change { case_state(c4s3) }.to('packaging')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:packaging])
      end

      it 'should set `planned_finish_date` to `planned_sending_date`' do
        subject
        expect(case_attributes(c4s3)[:planned_finish_date])
          .to be == case_attributes(c4s3)[:planned_sending_date]
      end

      attributes = %i[
        pending_register_institution_name
        pending_register_institution_office_building
        pending_register_institution_office_city
        pending_register_institution_office_country_code
        pending_register_institution_office_country_name
        pending_register_institution_office_district
        pending_register_institution_office_house
        pending_register_institution_office_index
        pending_register_institution_office_region_code
        pending_register_institution_office_region_name
        pending_register_institution_office_room
        pending_register_institution_office_settlement
        pending_register_institution_office_street
        pending_register_number
        pending_register_operator_id
        pending_register_operator_middle_name
        pending_register_operator_name
        pending_register_operator_position
        pending_register_operator_surname
        pending_register_sending_date
      ]
      it_should_behave_like 'an attributes cleaner', attributes

      context 'when case result was rejected' do
        let(:rejecting_date) { 'yesterday' }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when case state is switching from `pending` to `rejecting`' do
      include SDFullAutoCase::ChangeStateTo::PendingRejectingSpecHelper

      let(:c4s3) { create_case(:pending, rejecting_date) }
      let(:rejecting_date) { 'yesterday' }
      let(:params) { {} }
      let(:state) { 'rejecting' }

      it 'should set case state to `packaging`' do
        expect { subject }.to change { case_state(c4s3) }.to('rejecting')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:rejecting])
      end

      it 'should set `planned_finish_date` properly' do
        subject
        expect(case_attributes(c4s3)[:planned_finish_date])
          .to be == case_attributes(c4s3)[:planned_rejecting_finish_date]
      end

      attributes = %i[
        pending_rejecting_register_institution_name
        pending_rejecting_register_institution_office_building
        pending_rejecting_register_institution_office_city
        pending_rejecting_register_institution_office_country_code
        pending_rejecting_register_institution_office_country_name
        pending_rejecting_register_institution_office_district
        pending_rejecting_register_institution_office_house
        pending_rejecting_register_institution_office_index
        pending_rejecting_register_institution_office_region_code
        pending_rejecting_register_institution_office_region_name
        pending_rejecting_register_institution_office_room
        pending_rejecting_register_institution_office_settlement
        pending_rejecting_register_institution_office_street
        pending_rejecting_register_number
        pending_rejecting_register_operator_id
        pending_rejecting_register_operator_middle_name
        pending_rejecting_register_operator_name
        pending_rejecting_register_operator_position
        pending_rejecting_register_operator_surname
        pending_rejecting_register_sending_date
      ]
      it_should_behave_like 'an attributes cleaner', attributes

      context 'when case result wasn\'t rejected' do
        let(:rejecting_date) { nil }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when case state is switching from `processing` to `issuance`' do
      include SDFullAutoCase::ChangeStateTo::ProcessingIssuanceSpecHelper

      let(:c4s3) { create_case(:processing) }
      let(:params) { {} }
      let(:state) { 'issuance' }

      it 'should set case state to `issuance`' do
        expect { subject }.to change { case_state(c4s3) }.to('issuance')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:issuance])
      end

      it 'should set `issuance_receiving_date` attribute' do
        subject
        expect(case_issuance_receiving_date(c4s3))
          .to be_within(1)
          .of(Time.now)
      end

      it 'should set `planned_finish_date` properly' do
        subject
        expect(case_attributes(c4s3)[:planned_finish_date])
          .to be == case_attributes(c4s3)[:planned_issuance_finish_date]
      end

      attributes = %i[
        issuance_office_mfc_building
        issuance_office_mfc_city
        issuance_office_mfc_country_code
        issuance_office_mfc_country_name
        issuance_office_mfc_district
        issuance_office_mfc_house
        issuance_office_mfc_index
        issuance_office_mfc_region_code
        issuance_office_mfc_region_name
        issuance_office_mfc_room
        issuance_office_mfc_settlement
        issuance_office_mfc_street
        issuance_operator_id
        issuance_operator_middle_name
        issuance_operator_name
        issuance_operator_position
        issuance_operator_surname
        result_id
      ]
      it_should_behave_like 'an attributes setter', attributes
    end

    context 'when case state is switching from `issuance` to `closed`' do
      include SDFullAutoCase::ChangeStateTo::IssuanceClosedSpecHelper

      let(:c4s3) { create_case(:issuance, planned_rejecting_date) }
      let(:planned_rejecting_date) { (Time.now + 86_400).strftime('%FT%T') }
      let(:params) { {} }
      let(:state) { 'closed' }

      it 'should set case state to `closed`' do
        expect { subject }.to change { case_state(c4s3) }.to('closed')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:closed])
      end

      it 'should set `closed_date` attribute value to now time' do
        subject
        expect(case_closed_date(c4s3)).to be_within(1).of(Time.now)
      end

      it 'should set `planned_finish_date` to `nil`' do
        subject
        expect(case_attributes(c4s3)[:planned_finish_date]).to be_nil
      end

      attributes = %i[
        closed_office_mfc_building
        closed_office_mfc_city
        closed_office_mfc_country_code
        closed_office_mfc_country_name
        closed_office_mfc_district
        closed_office_mfc_house
        closed_office_mfc_index
        closed_office_mfc_region_code
        closed_office_mfc_region_name
        closed_office_mfc_room
        closed_office_mfc_settlement
        closed_office_mfc_street
        closed_operator_id
        closed_operator_middle_name
        closed_operator_name
        closed_operator_position
        closed_operator_surname
      ]
      it_should_behave_like 'an attributes setter', attributes

      context 'when `planned_rejecting_date` attribute is absent' do
        let(:c4s3) { create(:case, type: 'sd_full_auto_case') }
        let!(:attrs) { create(:case_attributes, **args) }
        let(:args) { { case_id: c4s3.id, state: 'issuance' } }

        it 'should set case state to `closed`' do
          expect { subject }.to change { case_state(c4s3) }.to('closed')
        end
      end

      context 'when `planned_rejecting_date` attribute is nil' do
        let(:planned_rejecting_date) { nil }

        it 'should set case state to `closed`' do
          expect { subject }.to change { case_state(c4s3) }.to('closed')
        end
      end

      context 'when `planned_rejecting_date` attribute value is invalid' do
        let(:planned_rejecting_date) { 'invalid' }

        it 'should set case state to `closed`' do
          expect { subject }.to change { case_state(c4s3) }.to('closed')
        end
      end

      context 'when now date is more than value of `planned_rejecting_date`' do
        let(:planned_rejecting_date) { Time.now - 24 * 60 * 60 }

        context 'when `close_on_reject` attribute value is absent' do
          it 'should raise RuntimeError' do
            expect { subject }.to raise_error(RuntimeError)
          end
        end

        context 'when `close_on_reject` attribute value is nil' do
          let!(:attr) { create(:case_attribute, attr_args) }
          let(:attr_args) { { name: name, value: nil, case_id: c4s3.id } }
          let(:name) { 'close_on_reject' }

          it 'should raise RuntimeError' do
            expect { subject }.to raise_error(RuntimeError)
          end
        end

        mark = described_class::RespondToMessage::CLOSE_ON_REJECT_MARK
        context "when `close_on_reject` attribute value is not `#{mark}`" do
          let!(:attr) { create(:case_attribute, attr_args) }
          let(:attr_args) { { name: name, value: value, case_id: c4s3.id } }
          let(:name) { 'close_on_reject' }
          let(:value) { 'not mark' }

          it 'should raise RuntimeError' do
            expect { subject }.to raise_error(RuntimeError)
          end
        end

        context "when `close_on_reject` attribute value is `#{mark}`" do
          let!(:attr) { create(:case_attribute, attr_args) }
          let(:attr_args) { { name: name, value: value, case_id: c4s3.id } }
          let(:name) { 'close_on_reject' }
          let(:value) { mark }

          it 'should set case state to `closed`' do
            expect { subject }.to change { case_state(c4s3) }.to('closed')
          end
        end
      end
    end

    context 'when case state is switching from `issuance` to `rejecting`' do
      include SDFullAutoCase::ChangeStateTo::IssuanceRejectingSpecHelper

      let(:c4s3) { create_case(:issuance, planned_rejecting_date) }
      let(:planned_rejecting_date) { Time.now - 24 * 60 * 60 }
      let(:params) { {} }
      let(:state) { 'rejecting' }

      it 'should set case state to `rejecting`' do
        expect { subject }.to change { case_state(c4s3) }.to('rejecting')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:rejecting])
      end

      it 'should set `rejecting_date` attribute value to now time' do
        subject
        expect(case_rejecting_date(c4s3)).to be_within(1).of(Time.now)
      end

      it 'should set `planned_finish_date` properly' do
        subject
        expect(case_attributes(c4s3)[:planned_finish_date])
          .to be == case_attributes(c4s3)[:planned_rejecting_finish_date]
      end

      context 'when `planned_rejecting_date` attribute is absent' do
        let(:c4s3) { create(:case, type: 'sd_full_auto_case') }
        let!(:attrs) { create(:case_attributes, **args) }
        let(:args) { { case_id: c4s3.id, state: 'issuance' } }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context 'when `planned_rejecting_date` attribute is nil' do
        let(:planned_rejecting_date) { nil }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context 'when `planned_rejecting_date` attribute value is invalid' do
        let(:planned_rejecting_date) { 'invalid' }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context 'when now date is less than value of `planned_rejecting_date`' do
        let(:planned_rejecting_date) { Time.now + 24 * 60 * 60 }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      mark = described_class::RespondToMessage::CLOSE_ON_REJECT_MARK
      context "when `close_on_reject` attribute value is `#{mark}`" do
        let!(:attr) { create(:case_attribute, attr_args) }
        let(:attr_args) { { name: name, value: value, case_id: c4s3.id } }
        let(:name) { 'close_on_reject' }
        let(:value) { mark }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when case state is switching from `pending` to `closed`' do
      include SDFullAutoCase::ChangeStateTo::PendingClosedSpecHelper

      let(:c4s3) { create_case('pending', *args) }
      let(:state) { 'closed' }
      let(:args) { [issue_method, rejecting_date] }
      let(:issue_method) { 'institution' }
      let(:rejecting_date) { nil }
      let(:params) { { operator_id: 'operator_id' } }

      it 'should set case state to `closed`' do
        expect { subject }.to change { case_state(c4s3) }.to('closed')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:closed])
      end

      it 'should set `closed_date` attribute value to now time' do
        subject
        expect(case_closed_date(c4s3)).to be_within(1).of(Time.now)
      end

      it 'should set `planned_finish_date` to `nil`' do
        subject
        expect(case_attributes(c4s3)[:planned_finish_date]).to be_nil
      end

      attributes = %i[
        closed_office_mfc_building
        closed_office_mfc_city
        closed_office_mfc_country_code
        closed_office_mfc_country_name
        closed_office_mfc_district
        closed_office_mfc_house
        closed_office_mfc_index
        closed_office_mfc_region_code
        closed_office_mfc_region_name
        closed_office_mfc_room
        closed_office_mfc_settlement
        closed_office_mfc_street
        closed_operator_id
        closed_operator_middle_name
        closed_operator_name
        closed_operator_position
        closed_operator_surname
      ]
      it_should_behave_like 'an attributes setter', attributes

      context 'when `issue_method` value isn\'t `institution`' do
        let(:issue_method) { '' }

        context 'when `rejecting_date` value is nil' do
          it 'should raise RuntimeError' do
            expect { subject }.to raise_error(RuntimeError)
          end
        end
      end
    end

    context 'when case state is switching from `pending` to `processing`' do
      include SDFullAutoCase::ChangeStateTo::PendingProcessingSpecHelper

      let(:c4s3) { create_case('pending', issue_method, rejecting_date) }
      let(:state) { 'processing' }
      let(:issue_method) { 'sd_full_auto_short' }
      let(:rejecting_date) { nil }
      let(:params) { {} }

      it 'should set case state to `processing`' do
        expect { subject }.to change { case_state(c4s3) }.to('processing')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:processing])
      end

      it 'should set `closed_date` attribute value to now time' do
        subject
        expect(case_processing_sending_date(c4s3)).to be_within(1).of(Time.now)
      end

      it 'should set `planned_finish_date` to `planned_receiving_date`' do
        subject
        expect(case_attributes(c4s3)[:planned_finish_date])
          .to be == case_attributes(c4s3)[:planned_receiving_date]
      end

      attributes = %i[
        processing_office_mfc_building
        processing_office_mfc_city
        processing_office_mfc_country_code
        processing_office_mfc_country_name
        processing_office_mfc_district
        processing_office_mfc_house
        processing_office_mfc_index
        processing_office_mfc_region_code
        processing_office_mfc_region_name
        processing_office_mfc_room
        processing_office_mfc_settlement
        processing_office_mfc_street
        processing_operator_id
        processing_operator_middle_name
        processing_operator_name
        processing_operator_position
        processing_operator_surname
      ]
      it_should_behave_like 'an attributes setter', attributes

      context 'when `issue_method` value is `institution`' do
        let(:issue_method) { 'institution' }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context 'when `rejecting_date` value is present' do
        let(:rejecting_date) { Time.now.strftime('%FT%T') }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end
  end

  describe '.on_case_creation' do
    include SDFullAutoCase::ChangeStateTo::NilSMEVSendingSpecHelper

    subject { described_class.on_case_creation(c4s3) }

    let(:c4s3) { create(:case, type: 'sd_full_auto_case') }
    let!(:planned_sending_date) { create(:case_attribute, *planned_traits) }
    let(:planned_traits) { [case_id: c4s3.id, name: name, value: value] }
    let(:name) { 'planned_sending_date' }
    let(:value) { Time.now.strftime('%d.%m.%Y') }

    it 'should set case state to `smev_sending`' do
      expect { subject }.to change { case_state(c4s3) }.to('smev_sending')
    end

    it 'should set `case_id` attribute value to case id value' do
      expect { subject }.to change { case_id(c4s3) }.to(c4s3.id)
    end

    it 'should set `case_status` attribute value to appropriate value' do
      expect { subject }
        .to change { case_status(c4s3) }
        .to(described_class::ChangeStateTo::CASE_STATUS[:smev_sending])
    end

    it 'should create request record and associate it with the case record' do
      expect { subject }.to change { c4s3.requests_dataset.count }.by(1)
    end

    it 'should publish the created request' do
      client = double
      allow(client).to receive(:publish)
      allow(Stomp::Client).to receive(:new).and_return(client)

      expect(client).to receive(:publish)
      subject
    end

    describe 'created request record' do
      subject(:request) { c4s3.requests_dataset.order(:created_at.asc).last }

      it 'should have `message_id` attribute' do
        described_class.on_case_creation(c4s3)
        expect(CaseCore::Actions::Requests.show(id: request.id))
          .to include('message_id')
      end
    end

    context 'when `case` argument is not of `CaseCore::Models::Case` type' do
      let(:c4s3) { 'not of `CaseCore::Models::Case` type' }
      let(:planned_traits) { [] }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when case type is wrong' do
      let(:c4s3) { create(:case, type: 'wrong') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case state is present' do
      let(:c4s3) { create(:case, type: 'sd_full_auto_case') }
      let!(:case_attribute) { create(:case_attribute, *traits) }
      let(:traits) { [case_id: c4s3.id, name: 'state', value: 'state'] }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe '.on_load' do
    subject { described_class.on_load }

    it 'should call `on_unload`' do
      expect(described_class).to receive(:on_unload).and_call_original
      subject
    end

    it 'should launch scheduler' do
      expect(described_class::Scheduler).to receive(:launch).and_call_original
      subject
    end

    it 'should schedule rejector' do
      expect(described_class::Scheduler)
        .to receive(:cron)
        .with(described_class::REJECTOR_CRON)
        .and_call_original
      subject
    end

    it 'should launch repeater' do
      expect(described_class::Repeater).to receive(:repeat)
      subject
    end
  end

  describe '.on_unload' do
    subject { described_class.on_unload }

    it 'should stop scheduler' do
      expect(described_class::Scheduler).to receive(:stop)
      subject
    end
  end

  describe '.on_responding_stomp_message' do
    before { described_class.on_load }
    after  { described_class.on_unload }

    include SDFullAutoCase::RespondToMessage::SpecHelper

    subject(:result) { described_class.on_responding_stomp_message(message) }

    let(:message) { create(:stomp_message, body: body) }
    let(:body) { Oj.dump(data) }
    let(:data) { { id: id, format: format, content: content, **attachments } }
    let(:attachments) { {} }
    let(:format) { 'EXCEPTION' }
    let(:content) { { special_data: special_data } }
    let(:id) { 'id' }
    let(:special_data) { '' }
    let!(:c4s3) { create_case(state, issue_method) }
    let(:state) { 'smev_sending' }
    let(:issue_method) { 'mfc' }
    let!(:request) { create_request(c4s3, message_id) }
    let(:message_id) { id }

    describe 'result' do
      subject { result }

      it { is_expected.to be_truthy }

      context 'when `message` argument is not of `Stomp::Message` type' do
        let(:message) { 'not of `Stomp::Message` type' }

        it { is_expected.to be_falsey }
      end

      context 'when message body is not a JSON-string' do
        let(:message) { create(:stomp_message, body: body) }
        let(:body) { 'not a JSON-string' }

        it { is_expected.to be_falsey }
      end

      context 'when message body is a JSON-string of wrong structure' do
        let(:message) { create(:stomp_message, body: body) }
        let(:body) { Oj.dump(wrong_structure) }
        let(:wrong_structure) { { wrong: :structure } }

        it { is_expected.to be_falsey }
      end

      context 'when request record is not found by message id' do
        let(:message_id) { 'won\'t be found' }

        it { is_expected.to be_falsey }
      end

      context 'when case has wrong type' do
        let(:c4s3) { create(:case, type: :wrong) }

        it { is_expected.to be_falsey }
      end

      context 'when case has wrong state' do
        let(:state) { 'wrong' }

        it { is_expected.to be_falsey }
      end
    end

    context 'when there are attachments' do
      let(:attachments) { { attachments: documents_list } }
      let(:documents_list) { [fs_id: 'fs_id'] }
      let(:fsa) { described_class::Base::MessageDrivenFSA }
      let(:file_body_request) { fsa::OutputFilesExtractor::FileBodyRequest }

      it 'should download files' do
        expect(file_body_request).to receive(:body).and_call_original
        subject
      end

      it 'should create file records' do
        expect { subject }.to change { CaseCore::Models::File.count }.by(1)
      end

      it 'should create document records' do
        expect { subject }.to change { CaseCore::Models::Document.count }.by(1)
      end
    end

    context 'when case state is `smev_sending`' do
      let(:state) { 'smev_sending' }

      it 'should set `response_content` request attribute to incoming data' do
        expect { subject }
          .to change { request_response_content(request) }
          .to(special_data)
      end

      it 'should set `response_format` request attribute to response format' do
        expect { subject }
          .to change { request_response_format(request) }
          .to(format)
      end

      context 'when `format` field of the message is `EXCEPTION`' do
        let(:format) { 'EXCEPTION' }

        it 'should set case state to `error`' do
          expect { subject }.to change { case_state(c4s3) }.to('error')
        end

        it 'should schedule repeat of the request' do
          expect(SDFullAutoCase::Scheduler).to receive(:in)
          subject
        end
      end

      context 'when `format` field of the message is `REJECTION`' do
        let(:format) { 'REJECTION' }

        context 'when `issue_method` of the case is `mfc`' do
          it 'should set case state to `issuance`' do
            expect { subject }.to change { case_state(c4s3) }.to('issuance')
          end

          it 'should set `issuance_receiving_date` case attribute to now' do
            subject
            expect(case_issuance_receiving_date(c4s3))
              .to be_within(1)
              .of(Time.now)
          end

          it 'should set `case_status` to appropriate value`' do
            subject
            expect(case_status(c4s3)).to be == case_status_issuance
          end

          it 'should set `close_on_reject` to appropriate value`' do
            subject
            expect(case_close_on_reject(c4s3)).to be == close_on_reject_mark
          end
        end

        context 'when `issue_method` of the case is not `mfc`' do
          let(:issue_method) { 'not mfc' }

          it 'should set case state to `closed`' do
            expect { subject }.to change { case_state(c4s3) }.to('closed')
          end

          it 'should set `closed_date` case attribute to now' do
            subject
            expect(case_closed_date(c4s3)).to be_within(1).of(Time.now)
          end

          it 'should set `case_status` to appropriate value`' do
            subject
            expect(case_status(c4s3)).to be == case_status_closed
          end
        end
      end

      context 'when `format` field of the message is `RESPONSE`' do
        let(:format) { 'RESPONSE' }

        context 'when `issue_method` of the case is `mfc`' do
          it 'should set case state to `issuance`' do
            expect { subject }.to change { case_state(c4s3) }.to('issuance')
          end

          it 'should set `issuance_receiving_date` case attribute to now' do
            subject
            expect(case_issuance_receiving_date(c4s3))
              .to be_within(1)
              .of(Time.now)
          end

          it 'should set `case_status` to appropriate value`' do
            subject
            expect(case_status(c4s3)).to be == case_status_issuance
          end

          it 'should set `close_on_reject` to appropriate value`' do
            subject
            expect(case_close_on_reject(c4s3)).to be == close_on_reject_mark
          end
        end

        context 'when `issue_method` of the case is not `mfc`' do
          let(:issue_method) { 'not mfc' }

          it 'should set case state to `closed`' do
            expect { subject }.to change { case_state(c4s3) }.to('closed')
          end

          it 'should set `closed_date` case attribute to now' do
            subject
            expect(case_closed_date(c4s3)).to be_within(1).of(Time.now)
          end

          it 'should set `case_status` to appropriate value`' do
            subject
            expect(case_status(c4s3)).to be == case_status_closed
          end
        end
      end
    end

    context 'when case state is `error`' do
      let(:state) { 'error' }

      it 'should set `response_content` request attribute to incoming data' do
        expect { subject }
          .to change { request_response_content(request) }
          .to(special_data)
      end

      it 'should set `response_format` request attribute to response format' do
        expect { subject }
          .to change { request_response_format(request) }
          .to(format)
      end

      context 'when `format` field of the message is `EXCEPTION`' do
        let(:format) { 'EXCEPTION' }

        context 'when there\'re only a few of requests with `EXCEPTION`' do
          it 'should schedule repeat of the request' do
            expect(SDFullAutoCase::Scheduler).to receive(:in)
            subject
          end

          it 'should keep case state' do
            expect { subject }.not_to change { case_state(c4s3) }
          end
        end

        context 'when there\'re lot of requests with `EXCEPTION` answer' do
          before { create_many_exceptional_requests(c4s3) }

          it 'shouldn\'t schedule repeat of the request' do
            expect(SDFullAutoCase::Scheduler).not_to receive(:in)
            subject
          end

          it 'should set case state to `packaging`' do
            expect { subject }.to change { case_state(c4s3) }.to('packaging')
          end

          it 'should set `case_status` to appropriate value`' do
            subject
            expect(case_status(c4s3)).to be == case_status_packaging
          end
        end
      end

      context 'when `format` field of the message is `REJECTION`' do
        let(:format) { 'REJECTION' }

        context 'when `issue_method` of the case is `mfc`' do
          it 'should set case state to `issuance`' do
            expect { subject }.to change { case_state(c4s3) }.to('issuance')
          end

          it 'should set `issuance_receiving_date` case attribute to now' do
            subject
            expect(case_issuance_receiving_date(c4s3))
              .to be_within(1)
              .of(Time.now)
          end

          it 'should set `case_status` to appropriate value`' do
            subject
            expect(case_status(c4s3)).to be == case_status_issuance
          end

          it 'should set `close_on_reject` to appropriate value`' do
            subject
            expect(case_close_on_reject(c4s3)).to be == close_on_reject_mark
          end
        end

        context 'when `issue_method` of the case is not `mfc`' do
          let(:issue_method) { 'not mfc' }

          it 'should set case state to `closed`' do
            expect { subject }.to change { case_state(c4s3) }.to('closed')
          end

          it 'should set `closed_date` case attribute to now' do
            subject
            expect(case_closed_date(c4s3)).to be_within(1).of(Time.now)
          end

          it 'should set `case_status` to appropriate value`' do
            subject
            expect(case_status(c4s3)).to be == case_status_closed
          end
        end
      end

      context 'when `format` field of the message is `RESPONSE`' do
        let(:format) { 'RESPONSE' }

        context 'when `issue_method` of the case is `mfc`' do
          it 'should set case state to `issuance`' do
            expect { subject }.to change { case_state(c4s3) }.to('issuance')
          end

          it 'should set `issuance_receiving_date` case attribute to now' do
            subject
            expect(case_issuance_receiving_date(c4s3))
              .to be_within(1)
              .of(Time.now)
          end

          it 'should set `case_status` to appropriate value`' do
            subject
            expect(case_status(c4s3)).to be == case_status_issuance
          end

          it 'should set `close_on_reject` to appropriate value`' do
            subject
            expect(case_close_on_reject(c4s3)).to be == close_on_reject_mark
          end
        end

        context 'when `issue_method` of the case is not `mfc`' do
          let(:issue_method) { 'not mfc' }

          it 'should set case state to `closed`' do
            expect { subject }.to change { case_state(c4s3) }.to('closed')
          end

          it 'should set `closed_date` case attribute to now' do
            subject
            expect(case_closed_date(c4s3)).to be_within(1).of(Time.now)
          end

          it 'should set `case_status` to appropriate value`' do
            subject
            expect(case_status(c4s3)).to be == case_status_closed
          end
        end
      end
    end
  end
end
