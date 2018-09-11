# frozen_string_literal: true

module SDFullAutoCase
  module Base
    class MessageDrivenFSA
      class OutputFilesExtractor
        # Класс запросов на тела файлов
        class FileBodyRequest
          include CaseCore::Requests::Get
          include CaseCore::Requests::Mixins::URL

          # Возвращает тело файла
          # @param [String] fs_id
          #   идентификатор файла в файловом хранилище
          # @return [String]
          #   тело файла
          def self.body(fs_id)
            new(fs_id).body
          end

          # Инициализирует экземпляр класса
          # @param [String] fs_id
          #   идентификатор файла в файловом хранилище
          def initialize(fs_id)
            @fs_id = fs_id
          end

          # Возвращает тело файла
          # @return [String]
          #   тело файла
          def body
            get.body
          end

          private

          # Идентификатор файла в файловом хранилище
          # @return [String]
          #   идентификатор файла в файловом хранилище
          attr_reader :fs_id

          # Возвращает адрес сервера файлового хранилища
          # @return [#to_s]
          #   адрес сервера
          def host
            ENV['CC_FS_HOST']
          end

          # Возвращает порт сервера файлового хранилища
          # @return [#to_s]
          #   порт сервера
          def port
            ENV['CC_FS_PORT']
          end

          # Шаблон пути, на который происходит запрос
          PATH_TEMPLATE = 'file-storage/api/files/%s?directory=mfc'

          # Возвращает путь, на который происходит запрос
          # @return [String]
          #   путь, на который происходит запрос
          def path
            format(PATH_TEMPLATE, fs_id)
          end
        end
      end
    end
  end
end
