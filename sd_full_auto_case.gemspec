# frozen_string_literal: true

require_relative 'lib/sd_full_auto_case/version.rb'

Gem::Specification.new do |spec|
  spec.name    = 'sd_full_auto_case'
  spec.version = SDFullAutoCase::VERSION
  spec.summary = 'Библиотека с бизнес-логикой услуги социальной защиты'

  spec.description = <<-DESCRIPTION.tr("\n", ' ').squeeze
    Библиотека с бизнес-логикой услуги социальной защиты для сервиса
    `case_core`. Поддерживает услуги, при оказании которых передача пакета
    документов и выдача результата осуществляется в электронном виде.
  DESCRIPTION

  spec.authors = ['Александр Ильчуков']
  spec.email   = 'a.s.ilchukov@cit.rkomi.ru'
  spec.files   = Dir['lib/**/*.rb']
end
