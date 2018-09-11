# frozen_string_literal: true

module SDFullAutoCase
  module Rejector
    # Вспомогательный модуль, подключаемый к тестам модуля
    # `SDFullAutoCase::Rejector`
    module SpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      # @param [Object] state
      #   статус заявки
      # @param [Hash]
      #   ассоциативный массив атрибутов
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      def create_case(state, attributes)
        FactoryBot.create(:case, type: 'sd_full_auto_case').tap do |c4s3|
          attributes = { case_id: c4s3.id, state: state.to_s, **attributes }
          FactoryBot.create(:case_attributes, **attributes)
        end
      end

      # Возвращает ассоциативный массив атрибутов заявки с предоставленным
      # идентификатором записи заявки
      # @param [Object] case_id
      #   идентификатор записи заявки
      def case_attributes(case_id)
        CaseCore::Actions::Cases.show_attributes(id: case_id)
      end

      # Возвращает объект с информацией о дате и времени, восстановленных из
      # значения атрибута заявки с предоставленным названием. Возвращает `nil`,
      # если атрибут отсутствует или его значение равно `nil`.
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @param [Symbol] name
      #   название атрибута
      # @return [Time]
      #   результирующий объект с информацией о дате и времени
      # @return [NilClass]
      #   если атрибут отсутствует или его значение равно `nil`
      def case_time_at(c4s3, name)
        value = case_attributes(c4s3.id)[name]
        value && Time.parse(value)
      end

      # Возвращает значение атрибута `state` заявки
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @return [NilClass, String]
      #   значение атрибута `state` или `nil`, если атрибут отсутствует или
      #   его значение пусто
      def case_state(c4s3)
        case_attributes(c4s3.id)[:state]
      end

      # Возвращает значение атрибута `rejecting_date` заявки
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @return [NilClass, Time]
      #   значение атрибута `rejecting_date` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      def case_rejecting_date(c4s3)
        case_time_at(c4s3, :rejecting_date)
      end
    end
  end
end
