# frozen_string_literal: true

module SDFullAutoCase
  module Base
    class MessageDrivenFSA
      # Вспомогательный модуль, предназначенный для включения в содержащий
      # класс
      module Helpers
        # Проверяет, что аргумент является объектом класса `Stomp::Message`
        # @param [Object] message
        #   аргумент
        # @raise [ArgumentError]
        #   если аргумент не является объектом класса `Stomp::Message`
        def check_message!(message)
          raise Errors::Message::BadType unless message.is_a?(Stomp::Message)
        end

        # Проверяет, что аргумент соответствует JSON-схеме
        # @param [Object] response_data
        #   аргумент
        # @raise [JSON::Schema::ValidationError]
        #   если аргумент не соответствует JSON-схеме
        def check_response_data!(response_data)
          JSON::Validator.validate!(ResponseDataSchema::SCHEMA, response_data)
        end

        # Проверяет, что аргумент является объектом класса
        # `CaseCore::Models::Case`
        # @param [Object] c4s3
        #   аргумент
        # @raise [ArgumentError]
        #   если аргумент не является объектом класса
        #   `CaseCore::Models::Case`
        def check_case!(c4s3)
          return if c4s3.is_a?(CaseCore::Models::Case)

          raise Errors::Case::InvalidClass
        end

        # Проверяет, что значение поля `type` записи заявки указывает на тот же
        # модуль бизнес-логики, что и корневой модуль
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        # @param [String] type
        #   тип корневого модуля
        # @raise [RuntimeError]
        def check_case_type!(c4s3, type)
          raise Errors::Case::BadType.new(c4s3, type) unless c4s3.type == type
        end

        # Проверяет, что запись запроса найдена
        # @param [NilClass, CaseCore::Models::Request] request
        #   запись запроса или `nil`
        # @param [#to_s] original_message_id
        #   идентификатор исходного сообщения STOMP
        # @raise [RuntimeError]
        #   если аргумент равен `nil`
        def check_request!(request, original_message_id)
          return unless request.nil?

          raise Errors::Request::NotFound.new(original_message_id)
        end

        # Проверяет, что из данного состояния возможно осуществить переход в
        # другое состояние согласно управляющему сообщению
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        # @param [Array<(String, String)>] control
        #   список из двух элементов: текущего состояния заявки и управляющего
        #   сообщения
        # @param [Hash] edges
        #   ассоциативный массив, содержащий в себе информацию о вершинах графа
        #   переходов состояния заявки и управляющих сообщениях
        # @raise [RuntimeError]
        #   если управляющему сообщению не соответствует никакая дуга из
        #   текущего состояния заявки
        def check_control!(c4s3, control, edges)
          return if edges.key?(control)

          raise Errors::Control::Absent.new(c4s3, control)
        end

        # Проверяет, что из данного состояния возможно осуществить переход в
        # другое состояние согласно условиям на дугах
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        # @param [Array<(String, String)>] control
        #   список из двух элементов: текущего состояния заявки и управляющего
        #   сообщения
        # @param [EdgeInfo, NilClass] edge_info
        #   информация о переходе или `nil`
        # @raise [RuntimeError]
        #   если из
        def check_edge!(c4s3, control, edge_info)
          raise Errors::Edge::Absent.new(c4s3, control) if edge_info.nil?
        end

        # Извлекает требуемые атрибуты заявки из соответствующих записей и
        # возвращает ассоциативный массив атрибутов заявки
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        # @param [Array] attrs
        #   список названий извлекаемых атрибутов
        # @return [Hash{Symbol => Object}]
        #   результирующий ассоциативный массив
        def extract_case_attributes(c4s3, attrs)
          CaseCore::Actions::Cases.show_attributes(id: c4s3.id, names: attrs)
        end

        # Регулярное выражение для извлечения типа модуля бизнес-логики
        TYPE_REGEXP = %r{lib\/([^\/].*)\/base\/message_driven_fsa}

        # Извлекает тип модуля бизнес-логики из пути текущего файла
        # @return [String]
        #   тип модуля бизнес-логики
        def type
          TYPE_REGEXP.match(__FILE__)[1]
        end
      end
    end
  end
end
