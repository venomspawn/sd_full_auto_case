# frozen_string_literal: true

# Поддержка эмуляции моделей в FactoryBot

FactoryBot.define do
  to_create { |obj| obj.class.datalist << obj }
end
