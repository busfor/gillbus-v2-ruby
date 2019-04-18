module Gillbus::V2
  module Structs
    # Базовый класс для работы со структурами данных.
    # Структуры в основном используются в качестве обертки над ответом API.
    #
    # Каждый объект хранит в себе 2 представления данных:
    # - raw_data - Hash с сырыми данными
    # - поля объекта, приведенные к нужным типам
    #
    # Это сделано для возможности сохранить объект и позже восстановить его:
    #
    # trip = search_response.trips.first
    # raw_data = trip.raw_data
    # ...
    # trip = Gillbus::V2::Structs::Trip.from_raw_data(raw_data)
    #
    # Все поля объекта будут восстановлены из raw_data.
    class Base
      attr_reader :raw_data

      # Тип данных Enum, пример испольования:
      #   field :my_field, Enum.("val1", "val2")
      # Поле данного типа может содержать либо значение из списка, либо nil.
      class Enum < Set
        def self.call(*elements)
          new(elements)
        end
      end

      def initialize(raw_data:, **fields)
        @raw_data = raw_data
        fields.each do |field_name, field_value|
          instance_variable_set(:"@#{field_name}", field_value)
        end
      end

      # Подробнее настройки поля можно изучить в Parser#parse_field.
      def self.field(name, type, from: name.to_s, default: nil, enrich_with: nil)
        attr_reader name
        @fields_settings ||= {}
        @fields_settings[name] = {
          type: type,
          from: from,
          default: default,
          enrich_with: enrich_with,
        }
      end

      def self.from_raw_data(raw_data)
        # Данные в raw_data никогда не должны меняться, чтобы объект всегда можно было воссоздать из raw_data и получить тот же результат.
        raw_data.freeze

        fields = Parser.parse_fields(raw_data, @fields_settings)
        new(raw_data: raw_data, **fields)
      end
    end
  end
end
