# frozen_string_literal: true

module CaseCore
  module Helpers
    module Log
      private

      # Эмулирует соответствующий метод журналирования инфраструктуры
      # `case_core`
      # @param [Binding] _context
      #   контекст
      def log_error(_context, &block); end
    end
  end
end
