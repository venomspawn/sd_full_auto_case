# frozen_string_literal: true

require 'base64'

module SDFullAutoCase
  module Base
    class MessageDrivenFSA
      # Вспомогательный класс для сохранения входящих документов
      class OutputFilesExtractor
        load "#{__dir__}/output_files_extractor/file_body_request.rb"

        # Сохраняет входящие документы, прикрепляя их к заявке
        # @param [String] case_id
        #   идентификатор заявки
        # @param [Array<Hash>] attachments
        #   информация о входящих документах
        def self.extract(case_id, attachments)
          new(case_id, attachments).extract
        end

        # Инициализирует объект класса
        # @param [String] case_id
        #   идентификатор заявки
        # @param [Array<Hash>] attachments
        #   информация о входящих документах
        def initialize(case_id, attachments)
          @case_id = case_id
          @attachments = attachments
        end

        # Сохраняет входящие документы, прикрепляя их к заявке
        def extract
          attachments&.each(&method(:save_output_file))
        end

        private

        # Идентификатор заявки
        # @return [String]
        #   идентификатор заявки
        attr_reader :case_id

        # Информация о входящих документах
        # @return [Array<Hash>]
        #   информация о входящих документах
        attr_reader :attachments

        # Сохраняет входящий документ, прикрепляя его к заявке
        # @param [NilClass, Hash] document
        #   информация о документе или `nil`, если информация о документе
        #   отсутствует
        def save_output_file(document)
          fs_id = document&.[](:fs_id) || return
          file_body = FileBodyRequest.body(fs_id)
          decoded_body = decode_file_body(file_body)
          attributes = document_params(document, decoded_body)
          CaseCore::Actions::Documents.create(attributes)
        end

        # Декодирует тело файла из формата Base64 и возвращает декодированное
        # тело файла
        # @param [String] content
        #   тело файла в формате Base64
        # @return [String]
        #   декодированное тело файла
        def decode_file_body(content)
          index = content.index('base64,') + 7
          result = content[index..-1]
          Base64.decode64(result)
        end

        # Ассоциативный массив с заготовкой атрибутов документа
        DOCUMENT_ATTRS = {
          provided_as: 'original',
          direction:   'output',
          provided:    true
        }.freeze

        # Создаёт запись файла с предоставленным телом и возвращает
        # ассоциативный массив с атрибутами документа
        # @param [Hash] document
        #   ассоциативный массив с информацией о документе
        # @param [String] file_body
        #   тело файла
        # @return [Hash]
        #   ассоциативный массив с атрибутами документа
        def document_params(document, file_body)
          fs_id = CaseCore::Actions::Files.create(file_body)[:id]
          DOCUMENT_ATTRS.dup.tap do |attrs|
            attrs[:case_id]    = case_id
            attrs[:fs_id]      = fs_id
            attrs[:mime_type]  = document[:mime_type]
            attrs[:filename]   = document[:filename]
            attrs[:created_at] = Time.now.to_s
          end
        end
      end
    end
  end
end
