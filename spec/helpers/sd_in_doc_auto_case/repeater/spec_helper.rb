# frozen_string_literal: true

module SDFullAutoCase
  module Repeater
    # Вспомогательный модуль, подключаемый к тестам содержащего класса
    module SpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      def create_case(ereq_count)
        FactoryBot.create(:case, type: 'sd_full_auto_case').tap do |c4s3|
          args = { case_id: c4s3.id, state: 'error' }
          FactoryBot.create(:case_attributes, **args)
          1.upto(ereq_count) do
            CaseCore::Actions::Requests
              .create(case_id: c4s3.id, response_format: 'EXCEPTION')
          end
        end
      end
    end
  end
end
