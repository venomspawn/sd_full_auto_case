# frozen_string_literal: true

load "#{__dir__}/base/state_driven_fsa.rb"
load "#{__dir__}/request/create.rb"

module SDFullAutoCase
  # Класс обработчиков события изменения состояния заявки
  # rubocop: disable Metrics/ClassLength
  class ChangeStateTo < Base::StateDrivenFSA
    # rubocop: enable Metrics/ClassLength
    load "#{__dir__}/change_state_to/dsl.rb"
    load "#{__dir__}/change_state_to/errors.rb"

    extend DSL

    # Значения атрибута `case_status`, выставляемые соответственно состоянию
    # заявки
    CASE_STATUS = {
      smev_sending: 'Отправка заявки в СМЭВ',
      packaging:    'Формирование пакета документов',
      pending:      'Ожидание отправки в ведомство',
      processing:   'Обработка пакета документов в ведомстве',
      issuance:     'Выдача результата оказания услуги',
      rejecting:    'Возврат невостребованного результата в ведомство',
      closed:       'Закрыта'
    }.freeze

    # Событие A (см. `docs/STATES.md`)
    edge nil:   :smev_sending,
         need:  %w[special_data service_id],
         set:   {
           case_creation_date: :now,
           case_id:            :case_id,
           case_status:        CASE_STATUS[:smev_sending]
         },
         after: Request::Create

    # C1
    edge packaging: :pending,
         need: :planned_sending_date,
         set: {
           case_status: CASE_STATUS[:pending],
           pending_register_sending_date: :now,
           planned_finish_date: :planned_sending_date,
           **from_params_with_the_same_names(
             :pending_register_institution_name,
             :pending_register_institution_office_building,
             :pending_register_institution_office_city,
             :pending_register_institution_office_country_code,
             :pending_register_institution_office_country_name,
             :pending_register_institution_office_district,
             :pending_register_institution_office_house,
             :pending_register_institution_office_index,
             :pending_register_institution_office_region_code,
             :pending_register_institution_office_region_name,
             :pending_register_institution_office_room,
             :pending_register_institution_office_settlement,
             :pending_register_institution_office_street,
             :pending_register_number,
             :pending_register_operator_id,
             :pending_register_operator_middle_name,
             :pending_register_operator_name,
             :pending_register_operator_position,
             :pending_register_operator_surname
           )
         }

    # C2
    edge pending: :packaging,
         need:    %i[rejecting_date planned_sending_date],
         check:   -> { !rejected? },
         raise:   Errors::PendingPackaging,
         set: {
           case_status: CASE_STATUS[:packaging],
           planned_finish_date: :planned_sending_date,
           **blank(
             :pending_register_institution_name,
             :pending_register_institution_office_building,
             :pending_register_institution_office_city,
             :pending_register_institution_office_country_code,
             :pending_register_institution_office_country_name,
             :pending_register_institution_office_district,
             :pending_register_institution_office_house,
             :pending_register_institution_office_index,
             :pending_register_institution_office_region_code,
             :pending_register_institution_office_region_name,
             :pending_register_institution_office_room,
             :pending_register_institution_office_settlement,
             :pending_register_institution_office_street,
             :pending_register_number,
             :pending_register_operator_id,
             :pending_register_operator_middle_name,
             :pending_register_operator_name,
             :pending_register_operator_position,
             :pending_register_operator_surname,
             :pending_register_sending_date
           )
         }

    # C3
    edge pending: :processing,
         need:    %w[issue_method rejecting_date planned_receiving_date],
         check:   -> { !issuance_in_institution? && !rejected? },
         raise:   Errors::PendingProcessing,
         set: {
           case_status: CASE_STATUS[:processing],
           processing_sending_date: :now,
           planned_finish_date: :planned_receiving_date,
           **from_params_with_the_same_names(
             :processing_office_mfc_building,
             :processing_office_mfc_city,
             :processing_office_mfc_country_code,
             :processing_office_mfc_country_name,
             :processing_office_mfc_district,
             :processing_office_mfc_house,
             :processing_office_mfc_index,
             :processing_office_mfc_region_code,
             :processing_office_mfc_region_name,
             :processing_office_mfc_room,
             :processing_office_mfc_settlement,
             :processing_office_mfc_street,
             :processing_operator_id,
             :processing_operator_middle_name,
             :processing_operator_name,
             :processing_operator_position,
             :processing_operator_surname
           )
         }

    # C4
    edge pending: :rejecting,
         need:    %i[rejecting_date planned_rejecting_finish_date],
         check:   -> { rejected? },
         raise:   Errors::PendingRejecting,
         set: {
           case_status: CASE_STATUS[:rejecting],
           planned_finish_date: :planned_rejecting_finish_date,
           **blank(
             :pending_rejecting_register_institution_name,
             :pending_rejecting_register_institution_office_building,
             :pending_rejecting_register_institution_office_city,
             :pending_rejecting_register_institution_office_country_code,
             :pending_rejecting_register_institution_office_country_name,
             :pending_rejecting_register_institution_office_district,
             :pending_rejecting_register_institution_office_house,
             :pending_rejecting_register_institution_office_index,
             :pending_rejecting_register_institution_office_region_code,
             :pending_rejecting_register_institution_office_region_name,
             :pending_rejecting_register_institution_office_room,
             :pending_rejecting_register_institution_office_settlement,
             :pending_rejecting_register_institution_office_street,
             :pending_rejecting_register_number,
             :pending_rejecting_register_operator_id,
             :pending_rejecting_register_operator_middle_name,
             :pending_rejecting_register_operator_name,
             :pending_rejecting_register_operator_position,
             :pending_rejecting_register_operator_surname,
             :pending_rejecting_register_sending_date
           )
         }

    # C5
    edge rejecting: :pending,
         need:      :planned_rejecting_finish_date,
         set: {
           case_status: CASE_STATUS[:pending],
           pending_rejecting_register_sending_date: :now,
           planned_finish_date: :planned_rejecting_finish_date,
           **from_params_with_the_same_names(
             :pending_rejecting_register_institution_name,
             :pending_rejecting_register_institution_office_building,
             :pending_rejecting_register_institution_office_city,
             :pending_rejecting_register_institution_office_country_code,
             :pending_rejecting_register_institution_office_country_name,
             :pending_rejecting_register_institution_office_district,
             :pending_rejecting_register_institution_office_house,
             :pending_rejecting_register_institution_office_index,
             :pending_rejecting_register_institution_office_region_code,
             :pending_rejecting_register_institution_office_region_name,
             :pending_rejecting_register_institution_office_room,
             :pending_rejecting_register_institution_office_settlement,
             :pending_rejecting_register_institution_office_street,
             :pending_rejecting_register_number,
             :pending_rejecting_register_operator_id,
             :pending_rejecting_register_operator_middle_name,
             :pending_rejecting_register_operator_name,
             :pending_rejecting_register_operator_position,
             :pending_rejecting_register_operator_surname
           )
         }

    # C6
    edge pending: :closed,
         need:    %w[issue_method rejecting_date],
         check:   -> { issuance_in_institution? || rejected? },
         raise:   Errors::PendingClosed,
         set: {
           case_status: CASE_STATUS[:closed],
           closed_date: :now,
           planned_finish_date: nil,
           **from_params_with_the_same_names(
             :closed_office_mfc_building,
             :closed_office_mfc_city,
             :closed_office_mfc_country_code,
             :closed_office_mfc_country_name,
             :closed_office_mfc_district,
             :closed_office_mfc_house,
             :closed_office_mfc_index,
             :closed_office_mfc_region_code,
             :closed_office_mfc_region_name,
             :closed_office_mfc_room,
             :closed_office_mfc_settlement,
             :closed_office_mfc_street,
             :closed_operator_id,
             :closed_operator_middle_name,
             :closed_operator_name,
             :closed_operator_position,
             :closed_operator_surname
           )
         }

    # C7
    edge processing: :issuance,
         need:       :planned_issuance_finish_date,
         set: {
           case_status: CASE_STATUS[:issuance],
           issuance_receiving_date: :now,
           planned_finish_date: :planned_issuance_finish_date,
           **from_params_with_the_same_names(
             :issuance_office_mfc_building,
             :issuance_office_mfc_city,
             :issuance_office_mfc_country_code,
             :issuance_office_mfc_country_name,
             :issuance_office_mfc_district,
             :issuance_office_mfc_house,
             :issuance_office_mfc_index,
             :issuance_office_mfc_region_code,
             :issuance_office_mfc_region_name,
             :issuance_office_mfc_room,
             :issuance_office_mfc_settlement,
             :issuance_office_mfc_street,
             :issuance_operator_id,
             :issuance_operator_middle_name,
             :issuance_operator_name,
             :issuance_operator_position,
             :issuance_operator_surname,
             :result_id
           )
         }

    # C8
    edge issuance: :rejecting,
         need:     %i[planned_rejecting_date planned_rejecting_finish_date],
         check:    -> { !can_be_issued? },
         raise:    Errors::IssuanceRejecting,
         set: {
           case_status: CASE_STATUS[:rejecting],
           rejecting_date: :now,
           planned_finish_date: :planned_rejecting_finish_date
         }

    # C9
    edge issuance: :closed,
         need:     :planned_rejecting_date,
         check:    -> { can_be_issued? },
         raise:    Errors::IssuanceClosed,
         set: {
           case_status: CASE_STATUS[:closed],
           closed_date: :now,
           planned_finish_date: nil,
           **from_params_with_the_same_names(
             :closed_office_mfc_building,
             :closed_office_mfc_city,
             :closed_office_mfc_country_code,
             :closed_office_mfc_country_name,
             :closed_office_mfc_district,
             :closed_office_mfc_house,
             :closed_office_mfc_index,
             :closed_office_mfc_region_code,
             :closed_office_mfc_region_name,
             :closed_office_mfc_room,
             :closed_office_mfc_settlement,
             :closed_office_mfc_street,
             :closed_operator_id,
             :closed_operator_middle_name,
             :closed_operator_name,
             :closed_operator_position,
             :closed_operator_surname
           )
         }

    private

    # Модуль методов, подключаемых к объекту, в контексте которого происходят
    # проверки атрибутов при переходе по дуге графа переходов состояния заявки
    module CheckContextMethods
      # Значение атрибута `issue_method`, означающее, что результат оказания
      # услуги выдаётся в ведомстве
      ISSUE_METHOD_INSTITUTION = 'institution'

      # Возвращает, предполагается ли выдача результатов оказания услуги
      # непосредственно в ведомстве
      # @return [Boolean]
      #   предполагается ли выдача результатов оказания услуги непосредственно
      #   в ведомстве
      def issuance_in_institution?
        return false if issue_method.nil?

        issue_method.casecmp?(ISSUE_METHOD_INSTITUTION)
      end

      # Возвращает, присутствует ли атрибут `rejecting_date` с непустым
      # значением
      # @return [Boolean]
      #   присутствует ли атрибут `rejecting_date` с непустым значением
      def rejected?
        !rejecting_date.nil?
      end

      # Возвращает, больше ли дата, представленная в значении атрибута
      # `planned_rejecting_date`, текущей даты. Возвращает булево значение
      # `true`, если атрибут `planned_rejecting_date` отсутствует или содержит
      # значение, из которого невозможно восстановить дату.
      # @return [Boolean]
      #   результирующее булево значение
      def can_be_issued?
        Date.today < planned_rejecting_date.to_date
      rescue StandardError
        true
      end
    end

    # Дополняет объект, в контексте которого происходят проверки атрибутов при
    # переходе по дуге графа переходов состояния заявки, методами модуля
    # `CheckContextMethods`
    # @return [Object]
    #   результирующий объект
    def check_context
      super.extend(CheckContextMethods)
    end

    # Возвращает идентификатор записи заявки
    # @return [String]
    #   идентификатор записи заявки
    def case_id
      c4s3.id
    end

    # Возвращает строку с плановой датой, после которой результат оказания
    # услуги должен отправляться на возврат в ведомство.
    # @return [String]
    #   строка с плановой датой, после которой результат оказания услуги должен
    #   отправляться на возврат в ведомство.
    def planned_issuance_finish_date
      case_attributes[:planned_issuance_finish_date]
    end

    # Возвращает строку с плановой датой получения результата оказания услуги
    # из ведомства
    # @return [String]
    #   строка с плановой датой получения результата оказания услуги из
    #   ведомства
    def planned_receiving_date
      case_attributes[:planned_receiving_date]
    end

    # Возвращает строку с плановой датой отправки документов заявки в ведомство
    # @return [String]
    #   строка с плановой датой отправки документов заявки в ведомство
    def planned_sending_date
      case_attributes[:planned_sending_date]
    end

    # Возвращает строку с плановой датой, после которой возврат результата
    # оказания услуги должен считаться просроченным
    # @return [String]
    #   строка с плановой датой, после которой возврат результата оказания
    #   услуги должен считаться просроченным
    def planned_rejecting_finish_date
      case_attributes[:planned_rejecting_finish_date]
    end
  end
end
