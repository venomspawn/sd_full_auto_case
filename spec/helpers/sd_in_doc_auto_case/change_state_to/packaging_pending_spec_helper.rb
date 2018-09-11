# frozen_string_literal: true

require_relative 'spec_helper'

module SDFullAutoCase
  class ChangeStateTo
    # Вспомогательный модуль, подключаемый к тестам класса
    # `SDFullAutoCase::ChangeStateTo` при проверке перехода состояния
    # заявки из `packaging` в `pending`
    module PackagingPendingSpecHelper
      include SpecHelper

      # Создаёт запись заявки с необходимыми атрибутами
      # @param [Object] state
      #   статус заявки
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      def create_case(state)
        attributes = {
          institution_rguid:    FactoryBot.create(:string),
          back_office_id:       FactoryBot.create(:string),
          planned_sending_date: Time.now.strftime('%d.%m.%Y')
        }
        super(state, attributes)
      end
    end
  end
end
