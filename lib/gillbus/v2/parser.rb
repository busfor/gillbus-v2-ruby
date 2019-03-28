module Gillbus::V2
  class Parser
    def parse_fields(raw_data, fields_settings)
      result = {}
      fields_settings.each do |name:, type:, default:|
        raw_value = raw_data[name.to_s]
        result[name] =
          if raw_value.nil?
            default
          else
            coerce_value(raw_value, type)
          end
      end
      result
    end

    def coerce_value(value, type)
      case type
      when :string
        value.to_s
      when :integer
        value.to_i
      when :date_time_from_timestamp
        DateTime.strptime(value.to_s, "%s")
      else
        raise "Type #{type} not supported"
      end
    end
  end
end
