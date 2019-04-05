module Gillbus::V2
  class Parser
    def parse_fields(raw_data, fields_settings)
      result = {}
      fields_settings.each do |field|
        if field[:type] == :translations_hash && raw_data["translations"]
          result[field[:name]] =
            fetch_from_translations(raw_data["translations"], field[:from])
          next
        end

        raw_value =
          if field[:from].is_a?(Hash)
            field[:from].map { |key, value| [key, raw_data[value]] }.to_h
          else
            raw_data[field[:from]]
          end

        if field[:enrich_with]
          raw_value = enrich_data(raw_value, raw_data, field[:enrich_with])
        end

        result[field[:name]] =
          if raw_value.nil?
            field[:default]
          else
            coerce_value(raw_value, field[:type])
          end
      end
      result
    end

    private

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

    def coerce_value(value, type)
      case type
      when :boolean
        value
      when :string
        value.to_s
      when :integer
        value.to_i
      when :float
        value.to_f
      when :date
        Date.parse(value)
      when :date_time_hh_mm
        DateTime.strptime(value, '%Y-%m-%d %H:%M')
      when :date_time_rfc3339
        DateTime.rfc3339(value)
      when :date_time_timestamp
        DateTime.strptime(value.to_s, "%s")
      when :time_interval_from_minutes
        value.to_i * 60
      when :translations_hash
        value.to_h
      when Array
        inner_type = type.first
        if value.is_a?(Array)
          value.map { |item| coerce_value(item, inner_type) }
        else
          raise "Invalid value for #{type}: #{value.class}"
        end
      when Structs::Base::Enum
        type.include?(value) ? value : nil
      when Class
        if type < Structs::Base
          type.from_raw_data(value)
        elsif type <= Money
          if value[:amount] && value[:currency]
            Money.from_amount(value[:amount], value[:currency])
          end
        else
          raise "Type #{type} not supported"
        end
      end
    rescue StandardError
      # Временно игнорируем все ошибки в данных.
      # TODO: подумать над валидацией объектов.
      nil
    end

    def fetch_from_translations(translations, field_name)
      translations.each_with_object({}) do |item, result|
        result[item["lang"]] = item[field_name]
      end
    end
  end
end
