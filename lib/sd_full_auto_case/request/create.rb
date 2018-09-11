# frozen_string_literal: true

require 'securerandom'

module SDFullAutoCase
  # Пространство имён модулей, связанных с функционалом межведомственных
  # запросов
  module Request
    # Модуль, предоставляющий функцию `call`, которая создаёт запись
    # межведомственного запроса и публикует его в очереди
    module Create
      # Создаёт запись запроса, ассоциируя её с записью запроса, и публикует
      # запрос в очередь
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @param [Hash] case_attributes
      #   ассоциативный массив атрибутов заявки
      def self.call(c4s3, case_attributes)
        create(c4s3.id, case_attributes)
      end

      # Создаёт запись запрос, ассоциируя её с записью запроса с
      # предоставленным идентификатором, и публикует запрос в очередь
      # @param [String] case_id
      #   идентификатор записи заявки
      # @param [Hash] case_attributes
      #   ассоциативный массив атрибутов заявки
      def self.create(case_id, case_attributes)
        message_id = SecureRandom.uuid
        model = CaseCore::Actions::Requests
        model.create(case_id: case_id, message_id: message_id)
        publish_message(case_attributes, message_id)
      end

      # Название очереди, в которую публикуется сообщение STOMP
      QUEUE_NAME = 'smev3.queue'

      # Публикует запрос в очередь
      # @param [Hash] case_attributes
      #   ассоциативный массив атрибутов заявки
      # @param [String] message_id
      #   идентификатор сообщения
      def self.publish_message(case_attributes, message_id)
        message = message_data(case_attributes, message_id)
        message = Oj.dump(message)
        CaseCore::API::STOMP::Controller.publish(QUEUE_NAME, message, {})
      end

      # Название очереди, из которой ожидается ответное сообщение
      RESPONSE_QUEUE_NAME = 'case_core_smev3.response.queue'

      # Возвращает ассоциативный массив с информацией о запросе
      # @param [Hash] case_attributes
      #   ассоциативный массив атрибутов заявки
      # @param [String] message_id
      #   идентификатор сообщения
      def self.message_data(case_attributes, message_id)
        {
          queue:   RESPONSE_QUEUE_NAME,
          id:      message_id,
          content: case_attributes.slice(:special_data, :service_id)
        }
      end
    end
  end
end
