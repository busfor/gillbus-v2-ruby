module Gillbus::V2
  module Responses
    class Locations < Responses::Base
      def locations
        @locations ||= (json_body["locations"] || []).map do |item|
          Structs::Location.from_raw_data(item)
        end
      end

      def location_types
        @location_types ||= begin
          data = formatted_dictionaries["location_types"]&.values || []
          data.map do |item|
            Structs::LocationType.from_raw_data(item)
          end
        end
      end

      def location_sub_types
        @location_sub_types ||= begin
          data = formatted_dictionaries["location_subtypes"]&.values || []
          data.map do |item|
            Structs::LocationSubType.from_raw_data(item)
          end
        end
      end

      def location_additional_fields
        @location_additional_fields ||= begin
          data = formatted_dictionaries["location_data_type"]&.values || []
          data.map do |item|
            Structs::LocationAdditionalField.from_raw_data(item)
          end
        end
      end

      def pagination
        @pagination ||=
          if json_body["pages_info"]
            Structs::Pagination.from_raw_data(json_body["pages_info"])
          end
      end

      private

      def formatted_dictionaries
        @formatted_dictionaries ||=
          format_dictionaries(json_body["dictionaries"])
      end

      def format_dictionaries(dictionaries)
        result = {}
        return result unless dictionaries

        dictionaries.each do |lang, dicts|
          dicts.each do |dict_key, dict|
            dict.each do |item|
              item_id = item["id"]
              result[dict_key] ||= {}
              result[dict_key][item_id] ||= {}
              item.each do |item_attr, attr_value|
                if item_attr == "id"
                  result[dict_key][item_id][item_attr] ||= attr_value
                else
                  result[dict_key][item_id][item_attr] ||= {}
                  result[dict_key][item_id][item_attr][lang] = attr_value
                end
              end
            end
          end
        end

        result
      end
    end
  end
end
