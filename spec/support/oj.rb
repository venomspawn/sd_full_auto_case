# frozen_string_literal: true

# Настройка Oj

require 'oj'

Oj.default_options = { mode: :json, symbol_keys: true }
