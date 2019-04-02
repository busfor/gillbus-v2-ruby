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

        raw_value = raw_data[field[:from]]
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
      when :date_time
        DateTime.rfc3339(value)
      when :date_time_from_timestamp
        DateTime.strptime(value.to_s, "%s")
      when :translations_hash
        value.to_h
      else
        raise "Type #{type} not supported"
      end
    end

    def fetch_from_translations(translations, field_name)
      translations.each_with_object({}) do |item, result|
        result[item["lang"]] = item[field_name]
      end
    end
  end
end
