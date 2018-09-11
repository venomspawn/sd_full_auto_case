# frozen_string_literal: true

# Файл поддержки эмуляции действий над записями файлов сервиса `case_core`

module CaseCore
  module Actions
    module Files
      # Создаёт запись файла и возвращает объект, который
      #  содержит в себе идентификатор
      # @param [String] content
      #   тело файла
      # @return [Hash]
      #   объект с идентификатором
      def self.create(content)
        id = FactoryBot.create(:integer)
        args = { id: id, content: content, created_at: Time.now }
        Models::File.create(args)
        { id: id }
      end
    end
  end
end
