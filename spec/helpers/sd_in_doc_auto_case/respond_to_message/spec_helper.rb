# frozen_string_literal: true

module SDFullAutoCase
  class RespondToMessage
    # Вспомогательный модуль, подключаемый к тестам содержащего класса
    module SpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      # @param [Object] state
      #   статус заявки
      # @param [Object] issue_method
      #   тип места выдачи результата заявки
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      def create_case(state, issue_method)
        FactoryBot.create(:case, type: 'sd_full_auto_case').tap do |c4s3|
          args = { state: state, issue_method: issue_method }
          FactoryBot.create(:case_attributes, case_id: c4s3.id, **args)
          args = { case_id: c4s3.id, name: 'case_id', value: c4s3.id }
          FactoryBot.create(:case_attribute, args)
        end
      end

      # Возвращает ассоциативный массив атрибутов заявки с предоставленным
      # идентификатором записи заявки
      # @param [Object] case_id
      #   идентификатор записи заявки
      # @return [Hash{Symbol => Object}]
      #   результирующий ассоциативный массив
      def case_attributes(case_id)
        CaseCore::Actions::Cases.show_attributes(id: case_id)
      end

      # Возвращает значение атрибута `state` заявки
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @return [NilClass, String]
      #   значение атрибута `state` или `nil`, если атрибут отсутствует или
      #   его значение пусто
      def case_state(c4s3)
        case_attributes(c4s3.id)[:state]
      end

      # Возвращает значение атрибута `case_status` заявки
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @return [NilClass, String]
      #   значение атрибута `case_status` или `nil`, если атрибут отсутствует
      #   или его значение пусто
      def case_status(c4s3)
        case_attributes(c4s3.id)[:case_status]
      end

      # Возвращает значение атрибута `closed_date` заявки
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @return [NilClass, Time]
      #   значение атрибута `closed_date` или `nil`, если атрибут отсутствует
      #   или его значение пусто
      def case_closed_date(c4s3)
        value = case_attributes(c4s3.id)[:closed_date]
        value && Time.parse(value)
      end

      # Возвращает значение атрибута `issuance_receiving_date` заявки
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @return [NilClass, Time]
      #   значение атрибута `issuance_receiving_date` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      def case_issuance_receiving_date(c4s3)
        value = case_attributes(c4s3.id)[:issuance_receiving_date]
        value && Time.parse(value)
      end

      # Создаёт и возвращает запись запроса, прикреплённую к записи заявки, с
      # предоставленным значением атрибута `message_id`
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @param [Object] message_id
      #   значение атрибута `message_id` запроса
      def create_request(c4s3, message_id)
        CaseCore::Actions::Requests
          .create(case_id: c4s3.id, message_id: message_id)
      end

      # Создаёт записи запросов, ассоциированные с предоставленной записью
      # заявки, атрибут `response_format` которых равен `EXCEPTION`
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      def create_many_exceptional_requests(c4s3)
        max = SDFullAutoCase::Request::Repeat::MAX_EXCEPTIONS_COUNT + 1
        1.upto(max) do
          CaseCore::Actions::Requests
            .create(case_id: c4s3.id, response_format: 'EXCEPTION')
        end
      end

      # Возвращает ассоциативный массив атрибутов запроса с предоставленным
      # идентификатором записи
      # @param [Object] request_id
      #   идентификатор записи заявки
      # @return [Hash{Symbol => Object}]
      #   результирующий ассоциативный массив
      def request_attributes(request_id)
        CaseCore::Actions::Requests.show(id: request_id)
      end

      # Возвращает значение атрибута `response_content` запроса
      # @param [CaseCore::Models::Request] request
      #   запись запроса
      # @return [NilClass, String]
      #   значение атрибута `response_content` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      def request_response_content(request)
        request_attributes(request.id)['response_content']
      end

      # Возвращает значение атрибута `response_format` запроса
      # @param [CaseCore::Models::Request] request
      #   запись запроса
      # @return [NilClass, String]
      #   значение атрибута `response_format` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      def request_response_format(request)
        request_attributes(request.id)['response_format']
      end
    end
  end
end
