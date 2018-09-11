# frozen_string_literal: true

module SDFullAutoCase
  module Base
    class StateDrivenFSA
      # Модуль, предназначенный для включения в содержащий класс,
      # предоставляющий вспомогательные методы для использования в заполнении
      # новых значений атрибутов заявки
      module Utils
        # Формат строки с датой и временем (`ГГГГ-ММ-ДДTЧЧ:ММ:СС`) для метода
        # `now`
        NOW_TIME_FORMAT = '%FT%T'

        # Возвращает строку с информацией о текущих дате и времени в формате
        # {NOW_TIME_FORMAT}
        # @example
        #   now => '2018-03-30Т11:01:53'
        # @return [String]
        #   результирующая строка
        def now
          Time.now.strftime(NOW_TIME_FORMAT)
        end

        # Возвращает идентификатор оператора из параметров `operator_id` и
        # `exporter_id`
        # @return [Object]
        #   результирующий идентификатор оператора
        def person_id
          params[:operator_id] || params[:exporter_id]
        end
      end
    end
  end
end
