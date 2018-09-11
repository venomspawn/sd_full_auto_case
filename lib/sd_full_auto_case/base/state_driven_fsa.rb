# frozen_string_literal: true

require 'ostruct'

module SDFullAutoCase
  # Пространство имён для базового класса обработчиков события изменения
  # состояния заявки
  module Base
    # Базовый класс обработчиков события изменения состояния заявки, основанный
    # на графе переходов состояния заявки. Алфавитом входящих сигналов служат
    # названия состояний, в которые переходят заявки.
    class StateDrivenFSA
      Dir["#{__dir__}/state_driven_fsa/*.rb"].each(&method(:load))

      extend  Edges
      include Helpers
      include Utils

      # Инициализирует объект класса
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @param [Object] state
      #   выставляемый статус заявки
      # @param [Hash] params
      #   ассоциативный массив параметров
      # @raise [ArgumentError]
      #   если аргумент `c4s3` не является объектом класса
      #   `CaseCore::Models::Case`
      # @raise [ArgumentError]
      #   если аргумент `params` не является объектом класса `Hash`
      # @raise [RuntimeError]
      #   если значение поля `type` записи заявки указывает на иной модуль
      #   бизнес-логики, нежели корневой модуль
      def initialize(c4s3, state, params)
        check_case!(c4s3)
        check_case_type!(c4s3, type)
        check_params!(params)
        @c4s3 = c4s3
        @state = state.to_s
        @params = params || {}
        @case_attributes = extract_case_attributes(c4s3, all_needed_attrs)
      end

      # Осуществляет следующие действия согласно информации, ассоциированной с
      # дугой графа переходов состояния заявки.
      # 1.  Проверяет, возможно ли перейти из текущего состояния заявки в новое
      #     состояние.
      # 2.  Если с дугой ассоциирован параметр `check`, то вызывает функцию,
      #     являющегося значением параметра, без аргументов в контексте объекта
      #     типа `OpenStruct`, который создаётся на основе ассоциативного
      #     массива атрибутов заявки. Если функция возвращает булево значение
      #     `false` и с дугой ассоциирован параметр `raise`, значение которого
      #     является классом ошибок, то создаёт ошибку этого класса, передавая
      #     в конструктор запись заявки.
      # 3.  Если с дугой ассоциирован параметр `set`, то обновляет атрибуты
      #     заявки согласно ассоциативному массиву, который является значением
      #     параметра. Каждый ключ ассоциативного массива интерпретируется в
      #     качестве названия атрибута заявки, а соответствующее значение
      #     интерпретируется следующим образом.
      #     *   Если значение является названием метода экземпляра класса, то
      #         этот метод вызывается и результат вызова подставляется в
      #         качестве значения атрибута.
      #     *   Если значение не является названием метода экземпляра класса,
      #         то проверяется, является ли оно ключом ассоциативного массива
      #         параметров. Если это так, то в качестве значения атрибута
      #         берётся значение соответствующего параметра. Если нет, то в
      #         качестве значения атрибута берётся само исходное значение.
      # 4.  Если с дугой ассоциирован параметр `after`, то вызывает метод
      #     `call` объекта, являющегося значением параметра, с записью заявки и
      #     ассоциативным массивом атрибутов заявки в качестве аргументов.
      # @raise [RuntimeError]
      # @raise [RuntimeError]
      #   если выставление статуса невозможно для данного статуса заявки
      # @raise [RuntimeError]
      #   если функция, являющаяся значением параметра `check`, вернула булево
      #   значение `false` и с дугой ассоциирован параметр `raise`, являющийся
      #   классом ошибок
      def process
        edge = [case_attributes[:state], state]
        check_edge!(c4s3, edge, edges)
        edge_info = edges[edge]
        invoke_check(edge_info)
        update_case_attributes(edge_info)
        edge_info.after&.call(c4s3, case_attributes)
      end

      private

      # Запись заявки
      # @return [CaseCore::Models::Case]
      #   запись заявки
      attr_reader :c4s3

      # Выставляемый статус заявки
      # @return [String]
      #   выставляемый статус заявки
      attr_reader :state

      # Ассоциативный массив параметров обработчика события
      # @return [Hash]
      #   ассоциативный массив параметров обработчика события
      attr_reader :params

      # Ассоциативный массив атрибутов заявки
      # @return [Hash]
      #   ассоциативный массив атрибутов заявки
      attr_reader :case_attributes

      # Возвращает ассоциативный массив с информацией о графе переходов
      # состояния заявки, созданного с помощью Edges класса
      # @return [Hash{Array<(String, String)> => Edges::EdgeInfo}]
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
        attrs = infos.each_with_object(%w[state]) do |edge_info, memo|
          memo.concat(edge_info.need) unless edge_info.need.nil?
        end
        attrs.uniq
      end

      # Вызывает функцию, являющуюся значением параметра `check`, без
      # аргументов в контексте объекта типа `OpenStruct`, который создаётся на
      # основе ассоциативного массива атрибутов заявки. Если функция возвращает
      # булево значение `false` и с дугой ассоциирован параметр `raise`,
      # значение которого является классом ошибок, то создаёт ошибку этого
      # класса, передавая в конструктор запись заявки.
      # @param [EdgeInfo] edge_info
      #   объект с информацией о переходе по дуге графа переходов состояний
      #   состояния заявки
      # @raise [RuntimeError]
      #   если функция, являющаяся значением параметра `check`, вернула булево
      #   значение `false` и с дугой ассоциирован параметр `raise`, являющийся
      #   классом ошибок
      def invoke_check(edge_info)
        return unless edge_info.check.is_a?(Proc)

        result = check_context.instance_exec(&edge_info.check)
        return unless result.is_a?(FalseClass)
        return unless edge_info.raise < RuntimeError

        raise edge_info.raise.new(c4s3)
      end

      # Обновляет атрибуты заявки согласно информации об их значениях
      # @param [EdgeInfo] edge_info
      #   объект с информацией о переходе по дуге графа переходов состояний
      #   состояния заявки
      def update_case_attributes(edge_info)
        attrs = new_case_attributes(edge_info)
        CaseCore::Actions::Cases.update(id: c4s3.id, state: state, **attrs)
      end

      # Составляет ассоциативный массив новых атрибутов заявки и возвращает его
      # @param [EdgeInfo] edge_info
      #   объект с информацией о переходе по дуге графа переходов состояний
      #   состояния заявки
      # @return [Hash]
      #   результирующий ассоциативный массив
      def new_case_attributes(edge_info)
        set = edge_info.set || {}
        set.each_with_object({}) do |(key, value_info), memo|
          value, skip = obtain_value(value_info)
          memo[key] = value unless skip
        end
      end

      # Возвращает список из двух элементов: извлечённого по аргументу значения
      # и булева флага, сигнализирующего о том, надо ли пропустить это значение
      # в ассоциативном массиве атрибутов
      # @param [Object] value_info
      #   аргумент
      # @return [Array<(Object, Boolean)>]
      #   список из двух элементов: извлечённого по аргументу значения и булева
      #   флага, сигнализирующего о том, надо ли пропустить это значение в
      #   ассоциативном массиве атрибутов
      def obtain_value(value_info)
        case value_info
        when String then extract_value(value_info, false)
        when Symbol then extract_value(value_info, true)
        else [value_info, false]
        end
      end

      # Возвращает список из двух элементов: извлечённого по аргументу
      # `value_info` значения и булева флага, сигнализирующего о том, надо ли
      # пропустить это значение в ассоциативном массиве атрибутов
      # @param [String, Symbol] value_info
      #   название метода экземпляра класса или ключа параметров
      # @param [Boolean] skip
      #   надо ли пропустить значение, если значение `value_info` не является
      #   названием ни метода экземпляра класса, ни ключа параметров
      # @return [Array<(Object, Boolean)>]
      #   список из двух элементов: извлечённого по аргументу `value_info`
      #   значения и булева флага, сигнализирующего о том, надо ли пропустить
      #   это значение в ассоциативном массиве атрибутов
      def extract_value(value_info, skip)
        if respond_to?(value_info, true)
          [send(value_info), false]
        elsif params.key?(value_info.to_sym)
          [params[value_info.to_sym], false]
        else
          [value_info, skip]
        end
      end

      # Возвращает объект, в контексте которого происходит проверка условий,
      # заданного параметром `check`
      # @return [Object]
      #   результирующий объект
      def check_context
        OpenStruct.new(case_attributes)
      end
    end
  end
end
