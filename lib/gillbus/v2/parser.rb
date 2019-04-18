module Gillbus::V2
  class Parser
    class << self
      # Парсит raw_data, не изменяя его!
      # Возвращает Hash из атрибутов со значениями, приведенными к своим типам.
      def parse_fields(raw_data, fields_settings)
        result = {}
        fields_settings.each do |field_name, field_settings|
          result[field_name] = parse_field(raw_data, field_settings)
        end
        result
      end

      def parse_field(raw_data, field_settings)
        field_type = field_settings[:type]
        fetch_from = field_settings[:from]
        default_value = field_settings[:default]
        enrich_with_attrs = field_settings[:enrich_with]

        raw_value =
          if field_type == :translations_hash && raw_data["translations"]
            # Иногда данные хранятся в отдельном поле translations,
            # разделенные по локалям. Cобираем данные по полю в хэш.
            fetch_from_translations(raw_data["translations"], fetch_from)
          elsif fetch_from.is_a?(Hash)
            # Для случаев когда нужно собрать объект из нескольких полей.
            # Например для Money нужны currency и amount.
            fetch_from.map { |key, value| [key, raw_data[value]] }.to_h
          else
            # В остальных случаях просто берем данные по ключу.
            raw_data[fetch_from]
          end

        return default_value if raw_value.nil?

        # Иногда необходимо обогащение записи дополнительными полями.
        # Например currency есть только в price, хотя нужна еще в тарифах.
        if enrich_with_attrs
          raw_value = enrich_data(raw_value, raw_data, enrich_with_attrs)
        end

        coerce_value(raw_value, field_type)
      end

      private

      # Достает значения поля из переводов, возвращает Hash.
      # Пример данных можно найти в test/gillbus/v2/structs/location_test.rb
      def fetch_from_translations(translations, field_name)
        translations.each_with_object({}) do |item, result|
          result[item["lang"]] = item[field_name]
        end
      end

      # Обогащение data из from_data полями из attrs_list.
      # Умеет работать с Hash и Array, для остальных возвращает входные данные.
      def enrich_data(data, from_data, attrs_list)
        enrich_with_data =
          attrs_list.each_with_object({}) do |attr_name, result|
            result[attr_name] = from_data[attr_name]
          end

        if data.is_a?(Hash)
          data.merge(enrich_with_data)
        elsif data.is_a?(Array) && data.all? { |item| item.is_a?(Hash) }
          data.map do |item|
            item.merge(enrich_with_data)
          end
        else
          data
        end
      end

      # Приведение значения к определенному типу.
      # В случае ошибок приведения для известных типов возвращает nil.
      def coerce_value(value, type)
        unless type.is_a?(Symbol)
          return coerce_to_complex_type(value, type)
        end

        case type
        when :boolean
          [true, false].include?(value) ? value : nil
        when :string
          value.to_s
        when :integer
          value.to_i
        when :float
          value.to_f
        when :date
          Date.parse(value) rescue nil
        when :date_time_hh_mm
          DateTime.strptime(value, '%Y-%m-%d %H:%M') rescue nil
        when :date_time_rfc3339
          DateTime.rfc3339(value) rescue nil
        when :date_time_timestamp
          DateTime.strptime(value.to_s, "%s") rescue nil
        when :translations_hash
          value.to_h
        else
          raise "Type #{type} not supported"
        end
      end

      # Обработка комплексных типов данных:
      # - Enum
      # - массивы объектов различного типа
      # - структуры данных (Structs::Base)
      # - Money
      def coerce_to_complex_type(value, type)
        if type.is_a?(Structs::Base::Enum)
          type.include?(value) ? value : nil
        elsif type.is_a?(Array) && type.size == 1
          if value.is_a?(Array)
            inner_type = type.first
            value.map { |item| coerce_value(item, inner_type) }
          end
        elsif type.is_a?(Class)
          if type < Structs::Base
            if value.is_a?(Hash)
              type.from_raw_data(value)
            end
          elsif type <= Money
            if value[:amount] && value[:currency]
              Money.from_amount(value[:amount], value[:currency])
            end
          else
            raise "Type #{type} is not supported"
          end
        else
          raise "Type #{type} is not supported"
        end
      end
    end
  end
end
