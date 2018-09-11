# frozen_string_literal: true

require 'json-schema'

module SDFullAutoCase
  module Base
    class MessageDrivenFSA
      # Класс объектов, содержащих информацию, ассоциированную с переходом по
      # дуге графа переходов состояния заявки
      class EdgeInfo
        # Ассоциативный массив с информацией о том, какие значения принимают
        # атрибуты заявки при переходе по дуге
        # @return [Hash]
        #   ассоциативный массив с информацией о том, какие значения принимают
        #   атрибуты заявки при переходе по дуге
        attr_reader :set

        # Список названий атрибутов, подлежащих извлечению при переходе по дуге
        # @return [Array<String>]
        #   список названий атрибутов, подлежащих извлечению при переходе по
        #   дуге
        attr_reader :need

        # Функция, выполняемая в контексте атрибутов заявки, значение которой
        # трактуется как выполнение условия на дугу
        # @return [Proc]
        #   функция условия
        attr_reader :if

        # Название состояния, в которое переводится заявке по данной дуге
        # @return [String]
        #    название состояния
        attr_reader :state

        # Объект, предоставляющий метод `call`, который принимает запись заявки
        # и ассоциативный массив её атрибутов в качестве аргументов
        # @return [#call]
        #   объект, предоставляющий метод `call`, который принимает запись
        #   заявки и ассоциативный массив её атрибутов в качестве аргументов
        attr_reader :after

        # Инициализирует объект класса
        # @param [Hash] options
        #   ассоциативный массив с информацией, ассоциированной с переходом по
        #   дуге
        # @raise [JSON::Schema::ValidationError]
        #   если аргумент не является ассоциативным массивом
        # @raise [JSON::Schema::ValidationError]
        #   если значение параметра `set` или `need` не является корректным
        def initialize(options)
          check_options!(options)
          @if    = options[:if]
          @set   = options[:set]
          @need  = Array(options[:need]).map(&:to_s)
          @state = options[:state].to_s
          @after = options[:after]
        end

        private

        # JSON-схема для проверки структуры аргумента конструктора экземпляров
        # класса
        OPTIONS_SCHEMA = {
          type: :object,
          properties: {
            set: {
              type: :object,
              additionalProperties: {
                type: %i[null string]
              }
            },
            need: {
              type: %i[string array],
              items: {
                type: :string
              }
            }
          }
        }.freeze

        # Проверяет структуру аргумента конструктора экземпляров класса
        # @param [Object] options
        #   аргумент конструктора
        # @raise [JSON::Schema::ValidationError]
        #   если аргумент не является ассоциативным массивом
        # @raise [JSON::Schema::ValidationError]
        #   если значение ключа `set` или `need` не является корректным
        def check_options!(options)
          JSON::Validator.validate!(OPTIONS_SCHEMA, options)
        end
      end
    end
  end
end
