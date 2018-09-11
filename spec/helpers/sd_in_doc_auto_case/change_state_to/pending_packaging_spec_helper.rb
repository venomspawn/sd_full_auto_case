# frozen_string_literal: true

require_relative 'spec_helper'

module SDFullAutoCase
  class ChangeStateTo
    # Вспомогательный модуль, подключаемый к тестам класса
    # `SDFullAutoCase::ChangeStateTo` при проверке перехода состояния
    # заявки из `pending` в `packaging`
    module PendingPackagingSpecHelper
      include SpecHelper

      # Названия атрибутов заявки, которые нужно заполнить
      ATTRIBUTE_NAMES = %i[
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
      ].freeze

      # Создаёт запись заявки с необходимыми атрибутами
      # @param [Object] state
      #   статус заявки
      # @param [Object] rejecting_date
      #   дата добавления в состояние `rejecting`
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      def create_case(state, rejecting_date)
        attributes = ATTRIBUTE_NAMES.each_with_object({}) do |name, memo|
          memo[name] = FactoryBot.create(:string)
        end
        attributes[:planned_sending_date] = Time.now.strftime('%d.%m.%Y')
        super(state, rejecting_date: rejecting_date, **attributes)
      end
    end
  end
end
