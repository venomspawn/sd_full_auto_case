# frozen_string_literal: true

# Файл поддержки эмуляции действий над записями документов сервиса `case_core`

module CaseCore
  module Actions
    module Documents
      # Создаёт запись документов и возвращает созданную запись
      # @param [Hash] hash
      #   ассоциативный массив атрибутов документа
      # @return [CaseCore::Models::Document]
      #   созданная запись
      def self.create(hash)
        Models::Document.create(hash)
      end
    end
  end
end
