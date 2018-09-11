# frozen_string_literal: true

load "#{__dir__}/base/message_driven_fsa.rb"
load "#{__dir__}/request/repeat.rb"

module SDFullAutoCase
  # Класс обработчиков события входящего сообщения STOMP
  class RespondToMessage < Base::MessageDrivenFSA
    # Значения атрибута `case_status`, выставляемые соответственно состоянию
    # заявки
    CASE_STATUS = {
      packaging: 'Формирование пакета документов',
      error:     'Ошибка при отправке заявки в СМЭВ',
      issuance:  'Выдача результата оказания услуги',
      closed:    'Закрыта'
    }.freeze

    # rubocop: disable Layout/AlignHash

    # B1 (см. `docs/STATES.md`)
    edge :smev_sending, error: :error,
         on:    :exception,
         if:    -> { repeat? },
         set:   {
           case_status: CASE_STATUS[:error]
         },
         need:  %w[case_id special_data service_id],
         after: Request::Repeat

    # B2
    edge :smev_sending, error: :packaging,
         on:    :exception,
         if:    -> { !repeat? },
         set:   {
           case_status: CASE_STATUS[:packaging],
           planned_finish_date: :planned_sending_date
         },
         need:  %i[case_id planned_sending_date],
         after: Request::Repeat

    # B3
    edge :smev_sending, error: :closed,
         on:    %i[rejection response],
         if:    -> { !mfc_issuance? },
         set:   {
           closed_date: :now,
           case_status: CASE_STATUS[:closed]
         },
         need:  :issue_method

    # B4
    edge :smev_sending, error: :issuance,
         on:    %i[rejection response],
         if:    -> { mfc_issuance? },
         set:   {
           case_status: CASE_STATUS[:issuance],
           issuance_receiving_date: :now,
           planned_finish_date: :planned_issuance_finish_date
         },
         need:  %i[issue_method planned_issuance_finish_date]

    # rubocop: enable Layout/AlignHash

    # Модуль методов, подключаемых к объекту, в контексте которого происходят
    # проверки атрибутов при переходе по дуге графа переходов состояния заявки
    module AttributesContextMethods
      # Возвращает, можно ли повторить запрос в СМЭВ
      # @return [Boolean]
      #   можно ли повторить запрос в СМЭВ
      def repeat?
        Request::Repeat.repeat?(case_id)
      end

      # Значение атрибута `issue_method`, означающее, что результат оказания
      # услуги выдаётся заявителю в офисе МФЦ
      ISSUE_METHOD_MFC = 'mfc'

      # Возвращает, происходит ли выдача в МФЦ
      # @return [Boolean]
      #   происходит ли выдача в МФЦ
      def mfc_issuance?
        issue_method.present? && ISSUE_METHOD_MFC.casecmp?(issue_method)
      end
    end

    # Возвращает объект типа `OpenStruct`, созданный на основе ассоциативного
    # массива атрибутов заявки, в контексте которого проверяются условия на
    # дугу
    # @param [Hash] case_attributes
    #   ассоциативный массив атрибутов заявки
    # @return [OpenStruct]
    #   результирующий объект
    def attributes_context(case_attributes)
      super.extend(AttributesContextMethods)
    end
  end
end
