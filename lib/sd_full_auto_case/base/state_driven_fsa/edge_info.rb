# frozen_string_literal: true

require 'json-schema'

module SDFullAutoCase
  module Base
    class StateDrivenFSA
      # Класс объектов, содержащих информацию, ассоциированную с переходом по
      # дуге графа переходов состояния заявки
      class EdgeInfo
        # Функция проверки условия на переход по дуге или `nil`, если такая
        # функция не задана
        # @return [Proc]
        #   функция проверки условия на переход по дуге
        # @return [NilClass]
        #   если функция проверки условия не задана
        attr_reader :check

        # Класс ошибок, создаваемых в случае, если функция проверки условия на
        # переход по дуге вернула булево значение `false`, или `nil`, если
        # класс ошибок не задан
        # @return [Class]
        #   класс ошибок, создаваемых в случае, если функция проверки условия
        #   на переход по дуге вернула булево значение `false`
        # @return [NilClass]
        #   если класс ошибок не задан
        attr_reader :raise

        # Ассоциативный массив с информацией о том, какие значения принимают
        # атрибуты заявки при переходе по дуге
        # @return [Hash]
        #   ассоциативный массив с информацией о том, какие значения принимают
        #   атрибуты заявки при переходе по дуге
        attr_reader :set

        # Список названий атрибутов, подлежащих извлечению для проверки условию
        # на переход по дуге
        # @return [Array<String>]
        #   список названий атрибутов, подлежащих извлечению для проверки
        #   условию на переход по дуге
        attr_reader :need

        # Объект, предоставляющий метод `call`, который принимает запись заявки
        # и ассоциативный массив её атрибутов в качестве аргументов, или `nil`
        # @return [NilClass, #call]
        #   объект, предоставляющий метод `call`, который принимает запись
        #   заявки и ассоциативный массив её атрибутов в качестве аргументов,
        #   или `nil`
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
          @after = options[:after]
          @check = options[:check]
          @raise = options[:raise]
          @set   = options[:set]
          @need  = Array(options[:need]).map(&:to_s)
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
