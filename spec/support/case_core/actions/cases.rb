# frozen_string_literal: true

# Файл поддержки эмуляции действий сервиса `case_core`

module CaseCore
  module Actions
    module Cases
      # Обновляет записи атрибутов, связанных с записью заявки
      # @param [Hash]
      #   ассоциативный массив значений атрибутов
      def self.update(params)
        case_ids = Array(params[:id])
        attrs = params.except(:id)
        names = attrs.keys.map(&:to_s)
        Models::CaseAttribute.where(case_id: case_ids, name: names).delete
        values = case_ids.each_with_object([]) do |case_id, memo|
          attrs.each do |(name, value)|
            memo << [case_id, name.to_s, value]
          end
        end
        Models::CaseAttribute.import(%i[case_id name value], values)
      end

      # Возвращает ассоциативный массив атрибутов записи заявки
      # @param [Hash{:id => String}] params
      #   ассоциативный массив параметров
      # @return [Hash]
      #   результирующий ассоциативный массив
      def self.show_attributes(params)
        args = { case_id: params[:id] }
        args[:name] = params[:names] unless params[:names].nil?
        attrs = Models::CaseAttribute.where(args)
        attrs.each_with_object({}) do |attr, memo|
          memo[attr.name.to_s.to_sym] = attr.value
        end
      end

      # Возвращает список ассоциативных массивов с идентификаторами заявок,
      # удовлетворяющих предоставленным условиям
      # @param [Hash] params
      #   ассоциативный массив параметров
      # @return [Array<Hash>]
      #   результирующий список
      def self.index(params)
        if params == SDFullAutoCase::Repeater::CASES_INDEX_PARAMS
          index_error
        else
          index_issuance(params)
        end
      end

      # Ассоциативный массив с параметрами запроса на извлечение записей заявок
      # в состоянии `issuance`
      INDEX_ARGS = { name: 'state', value: 'issuance' }.freeze

      # Путь для извлечения даты из ассоциативного массива параметров
      DATE_PATH = %i[filter planned_rejecting_date max].freeze

      # Возвращает список ассоциативных массивов с идентификаторами заявок в
      # состоянии `issuance`
      # @param [Hash] params
      #   ассоциативный массив параметров
      # @return [Array<Hash>]
      #   результирующий список
      def self.index_issuance(params)
        attributes = Models::CaseAttribute
        ids1 = attributes.where(INDEX_ARGS).select(:case_id)
        planned_rejecting_date = params.dig(*DATE_PATH)
        ids2 = attributes.datalist.each_with_object([]) do |obj, memo|
          memo << obj.case_id if obj.name == 'planned_rejecting_date' &&
                                 obj.value <= planned_rejecting_date
        end
        (ids1 & ids2).map { |id| { id: id } }
      end

      # Возвращает список ассоциативных массивов с идентификаторами заявок,
      # удовлетворяющих предоставленным условиям
      # @return [Array<Hash>]
      #   результирующий список
      def self.index_error
        attributes = Models::CaseAttribute
        args = { name: 'state', value: 'error' }
        ids = attributes.where(args).select(:case_id).uniq
        ids.map do |id|
          show_attributes(id: id)
            .slice(:special_data, :service_id)
            .merge(id: id)
        end
      end
    end
  end
end
