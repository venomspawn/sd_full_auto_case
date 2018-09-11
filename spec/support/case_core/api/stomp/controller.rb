# frozen_string_literal: true

# Файл поддержки эмуляции STOMP API сервиса `case_core`

module Stomp
  class Client
    def publish(*); end
  end

  class Message
    attr_reader :headers
    attr_reader :body

    # Инициализирует объект класса
    # @param [String] frame
    #   нуль-терминированная строка
    def initialize(frame)
      @headers = {}
      entries = frame.split("\n")
      entries.shift
      entries.each do |entry|
        break if entry.empty?

        key, value = entry.split(':')
        @headers[key] = value
      end
      @body = entries.last.chomp!("\0")
    end
  end
end

module CaseCore
  module API
    module STOMP
      module Controller
        def self.instance
          self
        end

        def self.publish(*)
          Stomp::Client.new.publish
        end
      end
    end
  end
end
