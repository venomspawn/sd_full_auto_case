# frozen_string_literal: true

# Файл поддержки эмуляции действий над записями запросов сервиса `case_core`

module CaseCore
  module Actions
    module Requests
      # Создаёт запись запроса с ассоциированными записями атрибутов и
      # возвращает созданную запись
      # @param [Hash] hash
      #   ассоциативный массив атрибутов запроса
      # @return [CaseCore::Models::Request]
      #   созданная запись
      def self.create(hash)
        request_id = FactoryBot.create(:integer)
        case_id = hash[:case_id]
        hash.except(:id, :case_id, :created_at).each do |name, value|
          args = { request_id: request_id, name: name.to_s, value: value }
          Models::RequestAttribute.create(args)
        end
        args = { id: request_id, case_id: case_id, created_at: Time.now }
        Models::Request.create(args)
      end

      # Ищет запись запроса по значению атрибута и возвращает найденную запись
      # или `nil`, если запись запроса невозможно найти
      # @param [Hash]
      #   ассоциативный массив атрибутов
      # @return [CaseCore::Models::Request]
      #   найденная запись
      # @return [NilClass]
      #   если запись не найдена
      def self.find(hash)
        name = hash.each_key.first.to_s
        value = hash.each_value.first
        attr = Models::RequestAttribute.where(name: name, value: value).first
        attr && Models::Request.where(id: attr.request_id).first
      end

      # Обновляет записи атрибутов, связанных с записью запроса
      # @param [Hash]
      #   ассоциативный массив значений атрибутов
      def self.update(params)
        request_id = params[:id]
        Models::RequestAttribute.where(request_id: request_id).delete
        attrs = params.except(:id)
        values = attrs.map { |name, value| [request_id, name, value] }
        Models::RequestAttribute.import(%i[request_id name value], values)
      end

      # Возвращает ассоциативный массив всех атрибутов записи запроса
      # @param [Hash{:id => String}] params
      #   ассоциативный массив параметров
      # @return [Hash]
      #   результирующий ассоциативный массив
      def self.show(params)
        request_id = params[:id]
        request = Models::Request.where(id: request_id).first
        request_values = Hash[request.members.zip(request.values)]
        attrs = Models::RequestAttribute.where(request_id: request_id)
        attrs.each_with_object(request_values) do |attr, memo|
          memo[attr.name.to_s] = attr.value
        end
      end

      # Возвращает количество записей запросов
      # @param [Hash]
      #   ассоциативный массив параметров
      # @return [Integer]
      #   результирующее количество
      def self.count(params)
        request_ids =
          Models::Request.where(case_id: params[:id]).select(:id)
        result = request_ids.inject(0) do |memo, id|
          attrs = show(id: id)
          inc = attrs['response_format'] == 'EXCEPTION' ? 1 : 0
          memo + inc
        end
        { count: result }
      end
    end
  end
end
