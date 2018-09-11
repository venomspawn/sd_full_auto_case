# frozen_string_literal: true

module SDFullAutoCase
  # Модуль, предоставляющий функции для добавления в планировщик заданий по
  # повторной отправке запросов
  module Repeater
    # Параметры функции `index` модуля `CaseCore::Actions::Cases`
    CASES_INDEX_PARAMS = {
      filter: { state: 'error' },
      fields: %w[special_data service_id]
    }.freeze

    # Добавляет в планировщик задания по повторной отправке запросов
    def self.repeat
      cases = CaseCore::Actions::Cases.index(CASES_INDEX_PARAMS)
      cases.each do |case_attributes|
        case_id = case_attributes[:id]
        SDFullAutoCase::Request::Repeat.repeat(case_id, case_attributes)
      end
    end
  end
end
