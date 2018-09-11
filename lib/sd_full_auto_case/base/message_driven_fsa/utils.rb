# frozen_string_literal: true

module SDFullAutoCase
  module Base
    class MessageDrivenFSA
      # Модуль, предназначенный для включения в содержащий класс,
      # предоставляющий вспомогательные методы для использования в заполнении
      # новых значений атрибутов заявки
      module Utils
        # Формат строки с датой и временем (`ГГГГ-ММ-ДДTЧЧ:ММ:СС`) для метода
        # `now`
        NOW_TIME_FORMAT = '%FT%T'

        # Возвращает строку с информацией о текущих дате и времени в формате
        # `ГГГГ-ММ-ДДTЧЧ:ММ:СС`
        # @return [String]
        #   результирующая строка
        def now
          Time.now.strftime(NOW_TIME_FORMAT)
        end
      end
    end
  end
end
