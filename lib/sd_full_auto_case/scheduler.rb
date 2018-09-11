# frozen_string_literal: true

require 'rufus-scheduler'

module SDFullAutoCase
  # Модуль, предоставляющий функции для управления планировщиком
  module Scheduler
    # Создаёт и запускает планировщик, останавливая предыдущий, если тот
    # присутствовал
    def self.launch
      stop
      @scheduler = Rufus::Scheduler.new
    end

    # Останавливает планировщик, если тот присутствовал
    def self.stop
      @scheduler&.stop
      @scheduler = nil
    end

    # Вызывает блок через заданное время (см. формат метода `in` экземпляра
    # класса `Rufus::Scheduler`)
    # @param [String] time
    #   строка с заданным временем
    def self.in(time, &block)
      @scheduler.in(time, &block)
    end

    # Вызывает блок по расписанию, представленному cron-строкой
    # @param [String] cron
    #   cron-строка расписания
    def self.cron(cron, &block)
      @scheduler.cron(cron, &block)
    end
  end
end
