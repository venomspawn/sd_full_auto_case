# frozen_string_literal: true

module CaseCore
  module Requests
    # Модуль эмуляции поддержки GET-запросов на внешние ресурсы
    module Get
      private

      # Класс эмуляции ответа
      Response = Struct.new(:body)

      # Возвращает ответ на запрос
      # @return [Response]
      #   ответ на запроса
      def get(*_args)
        body = 'application/pdf;base64,' + Base64.encode64('result')
        Response.new(body)
      end
    end
  end
end
