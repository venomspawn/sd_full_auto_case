# frozen_string_literal: true

require 'ostruct'

module SDFullAutoCase
  module Base
    # Класс обработчиков события `on_responding_stomp_message` на ответное
    # сообщение STOMP
    class MessageDrivenFSA
      Dir["#{__dir__}/message_driven_fsa/*.rb"].each(&method(:load))

      extend  Edges
      include Helpers
      include Utils

      # Инициализирует объект класса
      # @param [Stomp::Message] message
      #   объект с информацией об ответном сообщении STOMP
      # @raise [ArgumentError]
      #   если аргумент `message` не является объектом класса `Stomp::Message`
      # @raise [Oj::ParseError]
      #   если тело сообщения STOMP не является JSON-строкой
      # @raise [JSON::Schema::ValidationError]
      #   если структура, восстановленная из тела сообщения STOMP, не
      #   удовлетворяет JSON-схеме
      def initialize(message)
        check_message!(message)
        response_data = Oj.load(message.body, symbol_keys: true)
        check_response_data!(response_data)
        @response_data = response_data
      end

      # Обрабатывает ответное сообщение STOMP
      # @raise [RuntimeError]
      #   если запись запроса не найдена
      # @raise [RuntimeError]
      #   если поле `type` записи заявки не равно `sd_full_auto_case`
      # @raise [RuntimeError]
      #   если статус заявки отличен от `processing`
      def process
        request = find_request!

        c4s3 = request.case
        edge_info, case_attributes = process_case(c4s3)

        OutputFilesExtractor.extract(c4s3.id, attachments)

        update_request_attributes(request)
        update_case_attributes(c4s3, edge_info)

        edge_info.after&.call(c4s3, case_attributes)
      end

      private

      # Ассоциативный массив с данными ответного сообщения STOMP
      # @return [Hash]
      #   ассоциативный массив с данными ответного сообщения STOMP
      attr_reader :response_data

      # Возвращает список ассоциативных массивов с информацией о вложенных
      # файлах или `nil`, если информация о вложенных файлах отсутствует
      # @return [NilClass, Array<Hash>]
      #   список ассоциативных массивов с информацией о вложенных файлах или
      #   `nil`, если информация о вложенных файлах отсутствует
      def attachments
        response_data[:attachments]
      end

      # Возвращает идентификатор исходного сообщения, на которое пришёл ответ
      # @return [String]
      #   идентификатор исходного сообщения
      def original_message_id
        response_data[:id]
      end

      # Возвращает тип сообщения
      # @return [String]
      #   тип сообщения
      def response_format
        response_data[:format]
      end

      # Возвращает содержимое ответа
      # @return [String]
      #   содержимое ответа
      def response_content
        response_data[:content][:special_data]
      end

      # Возвращает запись запроса
      # @return [CaseCore::Models::Request]
      #   запись запроса
      # @raise [RuntimeError]
      #   если запись запроса не найдена
      def find_request!
        CaseCore::Actions::Requests
          .find(message_id: original_message_id)
          .tap { |request| check_request!(request, original_message_id) }
      end

      # Обрабатывает запись заявки
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @raise [RuntimeError]
      #   если поле `type` записи заявки не равно `sd_full_auto_case`
      # @raise [RuntimeError]
      #   если статус заявки отличен от `processing`
      # @return [EdgeInfo, Hash]
      #   список из информации перехода по дуге и ассоциативного массива
      #   атрибутов заявки
      def process_case(c4s3)
        check_case_type!(c4s3, type)

        case_attributes = extract_case_attributes(c4s3, all_needed_attrs)

        control = [case_attributes[:state], response_format.downcase]
        check_control!(c4s3, control, edges)

        edge_infos = edges[control]
        edge_info = find_positive_info(case_attributes, edge_infos)
        check_edge!(c4s3, control, edge_info)

        [edge_info, case_attributes]
      end

      # Возвращает ассоциативный массив с информацией о графе переходов
      # состояния заявки
      # @return [Hash{Array<(String, String)> => Array<Edges::EdgeInfo>}]
      #   результирующий ассоциативный массив
      def edges
        self.class.edges
      end

      # Возвращает список названий всех атрибутов, извлекаемых при переходах
      # графа состояний заявки
      # @return [Array<String>]
      #   результирующий список
      def all_needed_attrs
        infos = edges.each_value
        attrs = infos.each_with_object(%w[state]) do |edge_infos, memo|
          edge_infos.each do |edge_info|
            memo.concat(edge_info.need) unless edge_info.need.nil?
          end
        end
        attrs.uniq
      end

      # Ищет первую дугу среди предоставленных, у которой условие отсутствует
      # или выполнено, и возвращает объект с информацией о ней. Возвращает
      # `nil`, если такая дуга отсутствует.
      # @param [Hash] case_attributes
      #   ассоциативный массив атрибутов заявки
      # @param [Array<EdgeInfo>] edge_infos
      #   список объектов с информацией, ассоциированной с дугами
      # @return [EdgeInfo]
      #   объект с информацией о найденной дуге
      # @return [NilClass]
      #   если искомая дуга не найдена
      def find_positive_info(case_attributes, edge_infos)
        context = attributes_context(case_attributes)
        edge_infos.find do |edge_info|
          edge_info.if.nil? || context.instance_exec(&edge_info.if)
        end
      end

      # Возвращает объект типа `OpenStruct`, созданный на основе ассоциативного
      # массива атрибутов заявки, в контексте которого проверяются условия на
      # дугу
      # @param [Hash] case_attributes
      #   ассоциативный массив атрибутов заявки
      # @return [OpenStruct]
      #   результирующий объект
      def attributes_context(case_attributes)
        OpenStruct.new(case_attributes)
      end

      # Обновляет атрибуты запроса
      # @param [CaseCore::Models::Request] request
      #   запись запроса
      def update_request_attributes(request)
        request_attrs = {
          response_format:  response_format,
          response_content: response_content
        }
        CaseCore::Actions::Requests.update(id: request.id, **request_attrs)
      end

      # Обновляет атрибуты заявки согласно информации об их значениях
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @param [EdgeInfo] edge_info
      #   объект с информацией о переходе по дуге графа переходов состояний
      #   состояния заявки
      def update_case_attributes(c4s3, edge_info)
        state = edge_info.state
        set = edge_info.set || {}
        values = set.each_value.map(&method(:obtain_value))
        attrs = Hash[set.keys.zip(values)]
        CaseCore::Actions::Cases.update(id: c4s3.id, state: state, **attrs)
      end

      # Если аргумент является названием метода экземпляра класса, то
      # возвращает результат вызова метода без аргументов, иначе возвращает
      # аргумент
      # @param [Object] value_info
      #   аргумент
      # @return [Object]
      #   результирующее значение
      def obtain_value(value_info)
        return value_info unless value_info.is_a?(String) ||
                                 value_info.is_a?(Symbol)
        return value_info unless respond_to?(value_info, true)

        send(value_info)
      end
    end
  end
end
