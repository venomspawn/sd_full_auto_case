# frozen_string_literal: true

module SDFullAutoCase
  # Модуль, предоставляющий функцию `reject` для выставления состояния «Возврат
  # результата в ведомство» заявкам
  module Rejector
    # Выставляет состояние «Возврат результата в ведомство» тем заявкам, чей
    # результат должен быть выдан, но срок выдачи истёк
    def self.reject
      cases = CaseCore::Actions::Cases.index(index_params)
      CaseCore::Actions::Cases.update(update_params(cases))
    end

    # Возвращает ассоциативный массив с параметрами действия извлечения
    # информации о заявках
    # @return [Hash]
    #   результирующий ассоциативный массив
    def self.index_params
      yesterday = Date.today - 1
      {
        filter: {
          type:                   'sd_full_auto_case',
          state:                  'issuance',
          planned_rejecting_date: { max: yesterday.to_s }
        },
        fields: %i[id]
      }
    end

    # Возвращает ассоциативный массив с параметрами действия обновления
    # атрибутов заявок
    # @param [Array<Hash>] cases
    #   список ассоциативных массивов атрибутов заявок
    # @return [Hash]
    #   результирующий ассоциативный массив
    def self.update_params(cases)
      {
        id:             cases.map { |c4s3| c4s3[:id] },
        state:          'rejecting',
        case_status:    ChangeStateTo::CASE_STATUS[:rejecting],
        rejecting_date: Time.now.strftime('%FT%T')
      }
    end

    private_class_method :index_params, :update_params
  end
end
