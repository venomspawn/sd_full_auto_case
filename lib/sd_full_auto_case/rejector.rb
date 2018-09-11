# frozen_string_literal: true

module SDFullAutoCase
  # Класс, предоставляющий функцию `reject` для выставления новых состояний
  # заявкам, у которых исёт срок выдачи результата
  class Rejector
    # Выставляет новые состояния заявкам, у которых истёк срок выдачи
    # результата
    def self.reject
      new.reject
    end

    # Выставляет новые состояния заявкам, у которых истёк срок выдачи
    # результата
    def reject
      CaseCore::Actions::Cases.update(update_to_close_params)
      CaseCore::Actions::Cases.update(update_to_reject_params)
    end

    private

    # Фильтр для извлечения заявок в состоянии `issuance`
    FILTER = { type: 'sd_full_auto_case', state: 'issuance' }.freeze

    # Возвращает строку с датой вчерашнего дня от текущего в формате ISO 8601
    # @return [String]
    #   результирующая строка
    def yesterday
      today = Date.today
      today -= 1
      today.to_s
    end

    # Возвращает ассоциативный массив с фильтром для извлечения заявок, у
    # которых истёк срок выдачи результата
    def filter
      FILTER.dup.tap { |h| h[:planned_rejecting_date] = { max: yesterday } }
    end

    # Список названий атрибутов заявок, подлежащих извлечению
    FIELDS = %i[id close_on_reject].freeze

    # Возвращает ассоциативный массив параметров извлечения информации о
    # заявках, у которых истёк срок выдачи результата
    # @return [Hash]
    #   результирующий ассоциативный массив
    def expired_cases_index_params
      { filter: filter, fields: FIELDS }
    end

    # Возвращает список ассоциативных массивов с информацией о заявках, у
    # которых истёк срок выдачи результата
    # @return [Array<Hash>]
    #   результирующий список
    def expired_cases
      @expired_cases ||=
        CaseCore::Actions::Cases.index(expired_cases_index_params)
    end

    # Возвращает список идентификаторов заявок, которым необходимо выставить
    # состояние `rejected`
    # @return [Array]
    #   результирующий список
    def expired_to_reject_cases_ids
      expired_cases.each_with_object([]) do |c4s3, memo|
        close_on_reject = c4s3[:close_on_reject]
        next if close_on_reject == RespondToMessage::CLOSE_ON_REJECT_MARK

        memo << c4s3[:id]
      end
    end

    # Возвращает список идентификаторов заявок, которым необходимо выставить
    # состояние `closed`
    # @return [Array]
    #   результирующий список
    def expired_to_close_cases_ids
      expired_cases.each_with_object([]) do |c4s3, memo|
        close_on_reject = c4s3[:close_on_reject]
        next unless close_on_reject == RespondToMessage::CLOSE_ON_REJECT_MARK

        memo << c4s3[:id]
      end
    end

    # Возвращает ассоциативный массив с параметрами действия обновления
    # атрибутов заявок, которым необходимо выставить состояние `rejected`
    # @return [Hash]
    #   результирующий ассоциативный массив
    def update_to_reject_params
      {
        id:             expired_to_reject_cases_ids,
        state:          'rejecting',
        case_status:    ChangeStateTo::CASE_STATUS[:rejecting],
        rejecting_date: Time.now.strftime('%FT%T')
      }
    end

    # Возвращает ассоциативный массив с параметрами действия обновления
    # атрибутов заявок, которым необходимо выставить состояние `closed`
    # @return [Hash]
    #   результирующий ассоциативный массив
    def update_to_close_params
      {
        id:          expired_to_close_cases_ids,
        state:       'closed',
        case_status: ChangeStateTo::CASE_STATUS[:closed],
        closed_date: Time.now.strftime('%FT%T')
      }
    end
  end
end
