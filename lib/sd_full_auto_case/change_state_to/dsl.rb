# frozen_string_literal: true

module SDFullAutoCase
  class ChangeStateTo
    # Модуль, предоставляющий дополнительные средста описания
    module DSL
      # Создаёт и возвращает ассоциативный массив, у которого ключи и значения
      # одинаковы
      # @param [Array] args
      #   список ключей и значений
      # @return [Hash]
      #   результирующий ассоциативный массив
      def from_params_with_the_same_names(*args)
        args.each_with_object({}) { |arg, memo| memo[arg] = arg }
      end

      # Создаёт и возвращает ассоциативный массив с предоставленными ключами,
      # значения которого равны `nil`
      def blank(*keys)
        keys.each_with_object({}) { |key, memo| memo[key] = nil }
      end
    end
  end
end
