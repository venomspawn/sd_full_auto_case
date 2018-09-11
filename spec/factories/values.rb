# frozen_string_literal: true

# Фабрика значений

FactoryBot.define do
  sequence(:uniq)

  # Целые числа в заданном диапазоне или без него
  factory :integer do
    transient do
      range nil
    end

    skip_create
    initialize_with do
      if range.nil? || range.size.nil? || range.size.zero?
        generate(:uniq)
      else
        range.min + generate(:uniq) % range.size
      end
    end
  end

  # Строки
  factory :string do
    transient do
      length nil
    end

    skip_create
    initialize_with { format("%0#{length}d", generate(:uniq).to_s) }
  end

  # Строки шестнадцатеричных чисел
  factory :hex, class: String do
    transient do
      length nil
    end

    skip_create
    initialize_with { format("%0#{length}x", generate(:uniq)) }
  end

  # Даты без времени
  factory :date do
    transient do
      year  nil
      month nil
      day   nil
    end

    skip_create
    initialize_with do
      y = year  || create(:integer, range: 1980..2000).to_s
      m = month || create(:integer, range: 1..12).to_s
      d = day   || create(:integer, range: 1..28).to_s
      Date.parse("#{y}-#{m}-#{d}")
    end
  end

  # Время без даты
  factory :time do
    transient do
      seconds nil
      minutes nil
      hours   nil
    end

    skip_create
    initialize_with do
      s = seconds || create(:integer, range: 0..59).to_s
      m = minutes || create(:integer, range: 0..59).to_s
      h = hours   || create(:integer, range: 0..23).to_s
      Time.parse("#{h}:#{m}:#{s}")
    end
  end

  # Время с датой
  factory :full_time, class: Time do
    transient do
      year  nil
      month nil
      day   nil
      hours   nil
      minutes nil
      seconds nil
    end

    skip_create
    initialize_with do
      dy = year    || create(:integer, range: 1980..2000).to_s
      dm = month   || create(:integer, range: 1..12).to_s
      dd = day     || create(:integer, range: 1..28).to_s
      th = hours   || create(:integer, range: 0..23).to_s
      tm = minutes || create(:integer, range: 0..59).to_s
      ts = seconds || create(:integer, range: 0..59).to_s
      Time.local(dy, dm, dd, th, tm, ts)
    end
  end

  # Булевы значения
  factory :boolean, class: Object do
    skip_create
    initialize_with { generate(:uniq).even? }
  end

  # Перечислимые значения
  factory :enum, class: Object do
    transient do
      values nil
    end

    skip_create
    initialize_with do
      values[create(:integer, range: 0...values.size)]
    end
  end

  # URL
  factory :url, class: String do
    skip_create
    initialize_with { "http://www.example.com/#{create(:string)}" }
  end

  # Содержимое в Base64
  factory :base64, class: String do
    skip_create
    initialize_with { Base64.encode64(create(:string)) }
  end
end
