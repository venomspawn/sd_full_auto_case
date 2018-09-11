# frozen_string_literal: true

module SDFullAutoCase
  module Base
    class MessageDrivenFSA
      class OutputFilesExtractor
        # Вспомогательный модуль, подключаемый к тестам содержащего класса
        module SpecHelper
          # Создаёт запись заявки с необходимыми атрибутами
          # @param [Object] state
          #   статус заявки
          # @return [CaseCore::Models::Case]
          #   созданная запись заявки
          def create_case(state)
            FactoryBot.create(:case, type: 'sd_full_auto_case').tap do |c4s3|
              args = { case_id: c4s3.id, state: state }
              FactoryBot.create(:case_attributes, **args)
            end
          end

          # Возвращает количество записей Document
          # @return [Integer]
          #   количество
          def documents_count
            CaseCore::Models::Document.count
          end

          # Возвращает количество записей File
          # @return [Integer]
          #   количество
          def files_count
            CaseCore::Models::File.count
          end
        end
      end
    end
  end
end
