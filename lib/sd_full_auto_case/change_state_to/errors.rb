# frozen_string_literal: true

module SDFullAutoCase
  class ChangeStateTo
    # Пространство имён классов ошибок, используемых содержащим классом
    module Errors
      # Класс ошибок, сигнализирующих о том, что невозможно перевести заявку
      # из состояния `pending` в состояние `packaging`
      class PendingPackaging < RuntimeError
        # Инициализирует объект класса
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        def initialize(c4s3)
          super(<<-MESSAGE.squish)
            Невозможно перевести заявку с идентификатором `#{c4s3.id}` из
            состояния `pending` (ожидание отправки в ведомство) в состояние
            `packaging` (формирование пакета документов), так как присутствует
            атрибут заявки `added_to_rejecting_at` и его значение непусто
          MESSAGE
        end
      end

      # Класс ошибок, сигнализирующих о том, что невозможно перевести заявку
      # из состояния `pending` в состояние `processing`
      class PendingProcessing < RuntimeError
        # Инициализирует объект класса
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        def initialize(c4s3)
          super(<<-MESSAGE.squish)
            Невозможно перевести заявку с идентификатором `#{c4s3.id}` из
            состояния `pending` (ожидание отправки в ведомство) в состояние
            `processing` (обработка заявки в ведомстве), так как либо значение
            атрибута заявки `issue_location_type` равно `institution`, либо
            присутствует атрибут заявки `added_to_rejecting_at`
          MESSAGE
        end
      end

      # Класс ошибок, сигнализирующих о том, что невозможно перевести заявку
      # из состояния `pending` в состояние `rejecting`
      class PendingRejecting < RuntimeError
        # Инициализирует объект класса
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        def initialize(c4s3)
          super(<<-MESSAGE.squish)
            Невозможно перевести заявку с идентификатором `#{c4s3.id}` из
            состояния `pending` (ожидание отправки в ведомство) в состояние
            `rejecting` (возврат результата заявки в ведомство), так как
            отсутствует атрибут заявки `added_to_rejecting_at`
          MESSAGE
        end
      end

      # Класс ошибок, сигнализирующих о том, что невозможно перевести заявку
      # из состояния `pending` в состояние `closed`
      class PendingClosed < RuntimeError
        # Инициализирует объект класса
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        def initialize(c4s3)
          super(<<-MESSAGE.squish)
            Невозможно перевести заявку с идентификатором `#{c4s3.id}` из
            состояния `pending` (ожидание отправки в ведомство) в состояние
            `closed` (заявка закрыта), так как значение атрибута заявки
            `issue_location_type` не равно `institution` или отсутствует
            атрибут заявки `added_to_rejecting_at`
          MESSAGE
        end
      end

      # Класс ошибок, сигнализирующих о том, что невозможно перевести заявку
      # из состояния `issuance` в состояние `rejecting`
      class IssuanceRejecting < RuntimeError
        # Инициализирует объект класса
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        def initialize(c4s3)
          super(<<-MESSAGE.squish)
            Невозможно перевести заявку с идентификатором `#{c4s3.id}` из
            состояния `issuance` (выдача результата заявки) в состояние
            `rejecting` (возврат результата заявки в ведомство), так как либо
            дата, после которой нельзя выдать заявку, ещё не наступила, либо
            она отсутствует, либо она в неверном формате
          MESSAGE
        end
      end

      # Класс ошибок, сигнализирующих о том, что невозможно перевести заявку
      # из состояния `issuance` в состояние `closed`
      class IssuanceClosed < RuntimeError
        # Инициализирует объект класса
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        def initialize(c4s3)
          super(<<-MESSAGE.squish)
            Невозможно перевести заявку с идентификатором `#{c4s3.id}` из
            состояния `issuance` (выдача результата заявки) в состояние
            `closed` (заявка закрыта), так как уже наступила дата, после
            которой нельзя выдать заявку
          MESSAGE
        end
      end
    end
  end
end
