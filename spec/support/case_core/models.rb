# frozen_string_literal: true

# Файл поддержки эмуляции моделей сервиса `case_core`

module CaseCore
  module Models
    module Model
      # Создаёт новую структуру, эмулирующую модель сервиса `case_core`
      # @param [Array<Symbol>]
      #   список названий полей структуры
      # @return [Class]
      #   результирующая структура
      def self.new(members)
        Struct.new(*members) do
          extend ClassMethods
          include InstanceMethods
        end
      end

      # Класс, эмулирующий выборку записей
      class Dataset
        include Enumerable

        # Инициализирует объект класса
        # @param [Array] array
        #   список записей выборки
        # @param [Class] model
        #   структура записей выборки
        def initialize(array, model)
          @array = array
          @model = model
        end

        # Удаляет записи выборки
        def delete
          array.each(&model.method(:remove))
        end

        # Возвращает количество записей выборки
        def count
          array.count
        end

        # Возвращает первый элемент выборки или `NilClass`, если выборка пуста
        # @return [Struct]
        #   первый элемент выборки
        # @return [NilClass]
        #   если выборка пуста
        def first
          array.first
        end

        # Возвращает последний элемент выборки или `NilClass`, если выборка
        # пуста
        # @return [Struct]
        #   последний элемент выборки
        # @return [NilClass]
        #   если выборка пуста
        def last
          array.last
        end

        # Перечисляет записи
        # @return [Enumerator]
        #   если блок не предоставлен
        # @yieldparam [Struct]
        #   запись выборки
        def each(&block)
          array.each(&block)
        end

        # Возвращает объект выборки
        # @return [CaseCore::Models::Model::Dataset]
        #   объект выборки
        def naked
          self
        end

        # Возвращает список значений поля записи с предоставленным названием
        # @param [Object] key
        #   название поля
        def select(key)
          array.map { |obj| obj[key] }
        end

        # Возвращает ассоциативный массив, ключами которого являются значения
        # экземпляров структуры по ключу, совпадающему со значением параметра
        # `key`, а значениями — списки списков значений, полученные по ключам,
        # совпадающим со значениями в списке `value_keys`
        # @param [Symbol] key
        #   название ключа, по значениям которого будет производиться
        #   группировка
        # @param [Array<Symbol>] value_keys
        #   названия ключей, значения которого попадут в значения
        #   ассоциативного массива
        # @return [Hash]
        #   результирующий ассоциативный массив
        def select_hash_groups(key, value_keys)
          offsets = value_keys.map(&model.members.method(:find_index))
          array.each_with_object({}) do |obj, memo|
            key_value = obj[key]
            memo[key_value] ||= []
            memo[key_value] << obj.values_at(*offsets)
          end
        end

        # Сортирует записи по возрастанию значений поля записей с
        # предоставленным названием и возвращает выборку на основе
        # отсортированного списка
        # @param [Symbol] key
        #   названием поля
        # @return [CaseCore::Models::Model::Dataset]
        #   результирующая выборка
        def order(key)
          sorted = array.sort { |a, b| a[key] <=> b[key] }
          Dataset.new(sorted, model)
        end

        private

        # Список записей выборки
        # @return [Array]
        #   список записей выборки
        attr_reader :array

        # Структура записей выборки
        # @return [Class]
        #   структура записей выборки
        attr_reader :model
      end

      # Модуль методов структуры
      module ClassMethods
        # Возвращает структуру, которую расширяет этот модуль
        # @return [Class]
        #   структура, которую расширяет этот модуль
        def dataset
          self
        end

        # Возвращает список экземпляров структуры
        # @return [Array]
        #   список экземпляров структуры
        def datalist
          @datalist ||= []
        end

        # Возвращает количество экземпляров структуры
        # @return [Integer]
        #   количество экземпляров структуры
        def count
          datalist.count
        end

        # Удаляет экземпляр из списка экземпляров
        # @param [Struct] obj
        #   экземпляр
        def remove(obj)
          datalist.delete(obj)
        end

        # Создаёт экземпляр структуры, помещает его в список `datalist` и
        # возвращает его
        # @param [Hash] hash
        #   ассоциативный массив атрибутов экземпляра структуры
        # @return [Object]
        #   созданный экземпляр
        def create(hash)
          new(*hash.values_at(*members)).tap(&datalist.method(:<<))
        end

        # Создаёт экземпляры структуры согласно предоставленным названиям и
        # значениям свойств, после чего помещает их в список `datalist`
        # @param [Array] prop_names
        #   названия свойств
        # @param [Array<Array>] values
        #   значения свойств
        def import(prop_names, values)
          values.each do |obj_values|
            hash = Hash[prop_names.zip(obj_values)]
            create(hash)
          end
        end

        # Ищет экземпляр структуры по предоставленным значениям полей и
        # возвращает его в случае успешного нахождения. Если такой экземпляр
        # невозможно найти, создаёт экземпляр структуры, помещает его в список
        # `datalist` и возвращает его
        # @param [Hash] hash
        #   ассоциативный массив атрибутов экземпляра структуры
        # @return [Object]
        #   результирующий экземпляр
        def find_or_create(hash)
          where(hash).first || create(hash)
        end

        # Возвращает выборку записей на основе точного совпадения значений
        # полей
        # @param [Hash] hash
        #   ассоциативный массив значений полей
        # @return [CaseCore::Models::Model::Dataset]
        #   результирующая выборка
        def where(hash)
          wrong_keys = hash.keys - members
          return Dataset.new([], self) unless wrong_keys.empty?

          array_hash = arrayfy_values(hash)
          array = datalist.find_all { |obj| include_values?(obj, array_hash) }
          Dataset.new(array, self)
        end

        private

        # Возвращает новый ассоциативный массив, построенный на основе
        # предоставленного, сохраняя ключи и преобразуя каждое значение в
        # одноэлементный список, если оно не является списком
        # @param [Hash] hash
        #   исходный ассоциативный массив
        # @return [Hash]
        #   построенный ассоциативный массив
        def arrayfy_values(hash)
          hash.each_with_object({}) { |(k, v), memo| memo[k] = Array(v) }
        end

        # Проверяет, что значения полей экземпляра структуры находятся в
        # соответствующих названиям полей значениях предоставленного
        # ассоциативного массива
        # @param [Struct] obj
        #   экземпляр структуры
        # @param [Hash{Symbol => Array}] array_hash
        #   ассоциативный массив, отображающий названия полей в списки значений
        def include_values?(obj, array_hash)
          array_hash.inject(true) do |memo, (k, array)|
            memo && array.include?(obj[k])
          end
        end
      end

      # Модуль методов экземпляров структуры
      module InstanceMethods
        # Обновляет значения полей соответственно предоствленному
        # ассоциативному массиву
        # @param [Hash]
        #   предоставленный ассоциативный массив
        def update(hash)
          hash.each { |k, v| self[k] = v }
        end
      end
    end

    Case             = Model.new %i[id type created_at]
    CaseAttribute    = Model.new %i[case_id name value]
    Request          = Model.new %i[id case_id created_at]
    RequestAttribute = Model.new %i[request_id name value]
    File             = Model.new %i[id content]
    Document         = Model.new %i[
      id
      case_id
      created_at
      title
      mime_type
      filename
      fs_id
      direction
    ]

    class Case
      # Возвращает выборку записей запросов, ассоциированных с записью заявки
      # @return [CaseCore::Models::Model::Dataset]
      #   результирующая выборка
      def requests_dataset
        Request.where(case_id: id)
      end

      def documents_dataset
        Document.where(case_id: id)
      end
    end

    class Request
      # Возвращает запись заявки, ассоциированную с записью запроса
      # @return [CaseCore::Models::Case]
      #   запись заявки, ассоциированную с записью запроса
      def case
        Case.where(id: case_id).first
      end
    end

    class Document
      def files_dataset
        File.where(fs_id: fs_id)
      end
    end

    module Asc
      # Эмуляция метода `asc`, внедряемого Sequel
      # @return [Symbol]
      #   возвращает объект, чей метод вызывается
      def asc
        self
      end
    end

    Symbol.include Asc
  end
end
