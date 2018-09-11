# frozen_string_literal: true

module SDFullAutoCase
  module Base
    class MessageDrivenFSA
      # Модуль, предоставляющий пространства имён исключений, создаваемых
      # содержащим классом
      module Errors
        # Пространство имён исключений, связанных с аргументом `message`
        # конструктора содержащего класса
        module Message
          # Класс исключений, сигнализирующих о том, что аргумент `message`
          # конструктора содержащего класса не является объектом класса
          # `Stomp::Message`
          class BadType < ArgumentError
            # Инциализирует объект класса
            def initialize
              super(<<-MESSAGE.squish)
                Аргумент `message` не является объектом класса `Stomp::Message`
              MESSAGE
            end
          end
        end

        # Пространство имён исключений, связанных с записями запросов
        module Request
          # Класс исключений, сигнализирующих о том, что запись запроса не была
          # найдена по идентификатору исходного сообщения STOMP
          class NotFound < RuntimeError
            # Инциализирует объект класса
            # @param [#to_s] original_message_id
            #   идентификатор исходного сообщения STOMP
            def initialize(original_message_id)
              super(<<-MESSAGE.squish)
                Запись межведомственного запроса не была найдена по
                идентификатору `#{original_message_id}` исходного сообщения
                STOMP
              MESSAGE
            end
          end
        end

        # Пространство имён исключений, связанных с записью заявки
        module Case
          # Класс исключений, сигнализирующих о том, что аргумент `c4s3`
          # конструктора содержащего класса не является объектом класса
          # `CaseCore::Models::Case`
          class InvalidClass < ArgumentError
            # Инциализирует объект класса
            def initialize
              super(<<-MESSAGE.squish)
                Аргумент `c4s3` не является объектом класса
                `CaseCore::Models::Case`
              MESSAGE
            end
          end

          # Класс исключений, сигнализирующих о том, что значение поля `type`
          # записи заявки не является допустимым
          class BadType < RuntimeError
            # Инициализирует объект класса
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            # @param [#to_s] type
            #   тип корневого модуля
            def initialize(c4s3, type)
              super(<<-MESSAGE.squish)
                Значение поля `type` записи заявки с идентификатором
                `#{c4s3.id}` не равно `#{type}`
              MESSAGE
            end
          end
        end

        # Пространство имён исключений, связанных с управляющими сигналами
        # графа переходов состояния заявки
        module Control
          # Класс исключений, сигнализирующих о том, что управляющему сигналу
          # не соответствует никакая дуга из текущего состояния заявки
          class Absent < RuntimeError
            # Инциализирует объект класса
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            # @param [Array<(String, String)>] control
            #   список из двух элементов: текущего состояния заявки и
            #   управляющего сообщения
            def initialize(c4s3, control)
              super(<<-MESSAGE.squish)
                Сообщению `#{control.last}` не соответствует никакой переход
                из состояния `#{control.first}` заявки с идентификатором записи
                `#{c4s3.id}`
              MESSAGE
            end
          end
        end

        # Пространство имён исключений, связанных с дугами графа переходов
        # состояния заявки и условиями на них
        module Edge
          # Класс исключений, сигнализирующих о том, что не нашлось дуги из
          # данного состояния заявки, для которой было бы выполнено её условие
          class Absent < RuntimeError
            # Инциализирует объект класса
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            # @param [Array<(String, String)>] control
            #   список из двух элементов: текущего состояния заявки и
            #   управляющего сообщения
            def initialize(c4s3, control)
              super(<<-MESSAGE.squish)
                Не выполнено ни одно условие для перехода заявки с
                идентификатором записи `#{c4s3.id}` из состояния
                `#{control.first}` согласно сообщению `#{control.last}`
              MESSAGE
            end
          end
        end
      end
    end
  end
end
