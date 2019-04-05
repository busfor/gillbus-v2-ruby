module Gillbus::V2
  module Structs
    class Base
      attr_reader :raw_data

      # field :my_field, Enum.("val1", "val2")
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

      def self.field(name, type, from: name.to_s, default: nil, enrich_with: nil)
        attr_reader name
        @fields_settings ||= []
        @fields_settings << {
          name: name,
          type: type,
          from: from,
          default: default,
          enrich_with: enrich_with,
        }
      end

      def self.from_raw_data(raw_data)
        fields = Parser.new.parse_fields(raw_data, @fields_settings)
        new(raw_data: raw_data, **fields)
      end
    end
  end
end
