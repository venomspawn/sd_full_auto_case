# frozen_string_literal: true

module SDFullAutoCase
  module Base
    class MessageDrivenFSA
      # Модуль, предоставляющий константу `SCHEMA`, в которой описана схема
      # структуры тела сообщения STOMP
      module ResponseDataSchema
        # Схема структуры тела сообщения STOMP
        SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: :string
            },
            format: {
              type: :string,
              enum: %w[EXCEPTION REJECTION RESPONSE]
            },
            content: {
              type: :object,
              properties: {
                special_data: {
                  type: :string
                }
              },
              required: %i[
                special_data
              ]
            },
            attachments: {
              type: :array,
              items: {
                type: %i[null object],
                properties: {
                  fs_id: {
                    type: :string
                  }
                },
                required: %i[
                  fs_id
                ]
              }
            }
          },
          required: %i[
            id
            format
            content
          ]
        }.freeze
      end
    end
  end
end
