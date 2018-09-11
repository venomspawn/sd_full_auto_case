# frozen_string_literal: true

module SDFullAutoCase
  module Request
    # Модуль, предоставляющий функцию `call`, которая добавляет в планировщик
    # задание на создание записи межведомственного запроса и его публикации в
    # очереди
    module Repeat
      # Время ожидания
      WAIT_TIME = '900s'

      # Максимальное количество запросов с ответом, несущим информацию об
      # ошибке, при котором осуществляется повторная отправка запроса
      MAX_EXCEPTIONS_COUNT = 10

      # Добавляет в планировщик задание на создание записи межведомственного
      # запроса и его публикации в очереди в случае, если в рамках заявки не
      # создано слишком много запросов с информацией об ошибке в ответах
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @param [Hash] case_attributes
      #   ассоциативный массив атрибутов заявки
      def self.call(c4s3, case_attributes)
        repeat(c4s3.id, case_attributes)
      end

      # Добавляет в планировщик задание на создание записи межведомственного
      # запроса и его публикации в очереди в случае, если в рамках заявки не
      # создано слишком много запросов с информацией об ошибке в ответах
      # @param [String] case_id
      #   идентификатор записи заявки
      # @param [Hash] case_attributes
      #   ассоциативный массив атрибутов заявки
      def self.repeat(case_id, case_attributes)
        return unless repeat?(case_id)

        Scheduler.in(WAIT_TIME) { Create.create(case_id, case_attributes) }
      end

      # Значение фильтра записей запросов с информацией об ошибке в ответах
      FILTER = { response_format: 'EXCEPTION' }.freeze

      # Возвращает количество записей запросов, ассоциированных с
      # предоставленной записью заявки, с информацией об ошибке в ответах
      # @param [String] case_id
      #   идентификатор записи заявки
      # @return [Integer]
      #   результирующее количество
      def self.exceptions_count(case_id)
        result = CaseCore::Actions::Requests.count(id: case_id, filter: FILTER)
        result[:count]
      end

      # Возвращает, не больше ли значение {exceptions_count} значения константы
      # {MAX_EXCEPTIONS_COUNT}
      # @return [Boolean]
      #   не больше ли значение {exceptions_count} значения константы
      #   {MAX_EXCEPTIONS_COUNT}
      def self.repeat?(case_id)
        exceptions_count(case_id) <= MAX_EXCEPTIONS_COUNT
      end
    end
  end
end
