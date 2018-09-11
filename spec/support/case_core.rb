# frozen_string_literal: true

# Файл поддержки эмуляции моделей и действий сервиса `case_core`

module CaseCore
  # Очищает все списки структур
  def self.clear_data
    Models.constants.each do |const|
      obj = Models.const_get(const)
      obj.datalist.clear if obj.respond_to?(:datalist)
    end
  end
end

RSpec.configure do |config|
  config.around(:each) do |example|
    example.run
    CaseCore.clear_data
  end
end
