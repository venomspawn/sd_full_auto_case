# frozen_string_literal: true

module SDFullAutoCase
  module Base
    class StateDrivenFSA
      # Вспомогательный модуль, предназначенный для включения в содержащий
      # класс
      module Helpers
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

        # Проверяет, что аргумент является объектом класса `NilClass` или
        # класса `Hash`
        # @params [Hash] params
        #   аргумент
        # @raise [ArgumentError]
        #   если аргумент не является объектом класса `Hash`
        def check_params!(params)
          raise Errors::Params::InvalidClass unless params.is_a?(Hash)
        end

        # Проверяет, что дуга принадлежит графу переходов состояния заявки
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        # @param [Array<(String, String)>] edge
        #   список из двух элементов: текущего состояния заявки и нового
        #   состояния заявки
        # @param [Hash] edges
        #   ассоциативный массив, в котором объекты с информацией о дугах графа
        #   переходов состояния заявки отображаются в дополнительную информацию
        #   о переходе
        # @raise [RuntimeError]
        #   если дуга не принадлежит графу
        def check_edge!(c4s3, edge, edges)
          raise Errors::Edge::Absent.new(c4s3, edge) unless edges.key?(edge)
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
        TYPE_REGEXP = %r{lib\/([^\/].*)\/base\/state_driven_fsa}

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
