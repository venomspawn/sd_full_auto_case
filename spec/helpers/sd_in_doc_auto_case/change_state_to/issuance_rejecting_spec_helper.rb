# frozen_string_literal: true

require_relative 'spec_helper'

module SDFullAutoCase
  class ChangeStateTo
    # Вспомогательный модуль, подключаемый к тестам класса
    # `SDFullAutoCase::ChangeStateTo` при проверке перехода состояния
    # заявки из `issuance` в `rejecting`
    module IssuanceRejectingSpecHelper
      include SpecHelper

      # Создаёт запись заявки с необходимыми атрибутами
      # @param [Object] state
      #   статус заявки
      # @param [Object] planned_rejecting_date
      #   дата, после которой результат заявки невозможно выдать
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      def create_case(state, planned_rejecting_date)
        attrs = {
          planned_rejecting_date:        planned_rejecting_date,
          planned_rejecting_finish_date: Time.now.strftime('%d.%m.%Y')
        }
        super(state, attrs)
      end
    end
  end
end
