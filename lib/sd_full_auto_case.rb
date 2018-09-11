# frozen_string_literal: true

require 'active_support/core_ext/hash/slice.rb'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/core_ext/string/filters.rb'
require 'oj'
require 'json-schema'

load "#{__dir__}/sd_full_auto_case/change_state_to.rb"
load "#{__dir__}/sd_full_auto_case/rejector.rb"
load "#{__dir__}/sd_full_auto_case/repeater.rb"
load "#{__dir__}/sd_full_auto_case/respond_to_message.rb"
load "#{__dir__}/sd_full_auto_case/scheduler.rb"
load "#{__dir__}/sd_full_auto_case/version.rb"

# Модуль, реализующий бизнес-логику услуги социальной защиты
module SDFullAutoCase
  extend CaseCore::Helpers::Log

  # Cron-строка расписания перевода заявок с просроченными сроками выдачи
  # результатов в состояние `rejected`
  REJECTOR_CRON = '0 0 * * *'

  # Вызывается при загрузке модуля
  def self.on_load
    on_unload
    Scheduler.launch
    Scheduler.cron(REJECTOR_CRON, &Rejector.method(:reject))
    Repeater.repeat
  end

  # Вызывается при выгрузке модуля
  def self.on_unload
    Scheduler.stop
  end

  # Выставляет начальный статус заявки `smev_sending` и создаёт запрос в СМЭВ
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  # @raise [RuntimeError]
  #   значение поля `type` записи заявки не равно `sd_full_auto_case`
  # @raise [RuntimeError]
  #   если заявка обладает выставленным статусом
  def self.on_case_creation(c4s3)
    ChangeStateTo.new(c4s3, 'smev_sending', {}).process
  end

  # Обрабатывает ответное сообщение
  # @param [Stomp::Message] message
  #   объект с информацией об ответном сообщении
  # @return [Boolean]
  #   была ли обработка успешна
  def self.on_responding_stomp_message(message)
    RespondToMessage.new(message).process
    true
  rescue StandardError => e
    log_error(binding) { <<-LOG }
      Во время обработки сообщения STOMP возникла ошибка `#{e.class}`:
      `#{e.message}`
    LOG
    false
  end

  # Выставляет статус заявки
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  # @param [Object] state
  #   выставляемый статус заявки
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  # @raise [ArgumentError]
  #   если аргумент `params` не является объектом класса `NilClass` или класса
  #   `Hash`
  # @raise [RuntimeError]
  #   значение поля `type` записи заявки не равно `sd_full_auto_case`
  def self.change_state_to(c4s3, state, params)
    ChangeStateTo.new(c4s3, state, params).process
  end
end
