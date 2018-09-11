# frozen_string_literal: true

# Фабрика объектов класса `Stomp::Message`, содержащих в себе информацию о
# сообщении STOMP

FactoryBot.define do
  factory :stomp_message, class: Stomp::Message do
    headers { { 'content-type' => 'text/plain' } }
    body    { 'body' }

    skip_create
    initialize_with do
      entries = create(:stomp_message_entries, headers: headers, body: body)
      frame = "#{entries.join("\n")}\0"
      Stomp::Message.new(frame)
    end
  end

  factory :stomp_message_entries, class: Array do
    command { 'MESSAGE' }
    headers { {} }
    body    { '' }

    skip_create
    initialize_with do
      entries = headers.each_with_object([command]) do |(name, value), memo|
        memo << "#{name}:#{value}"
      end
      entries.push('', body)
    end
  end
end
