module Gillbus::V2
  class Structs::Location < Structs::Base
    field :id, :integer
    field :parent_id, :integer
    field :country_id, :integer
    field :type_id, :integer
    field :sub_type_id, :integer, from: "subtype_id"

    field :date_modified, :date_time
    field :deleted, :boolean

    field :latitude, :float
    field :longitude, :float

    field :timezone, :string

    field :default_name, :string
    field :name, :translations_hash
    field :region_name, :translations_hash
    field :country_name, :translations_hash

    def additional_fields
      @additional_fields ||=
        raw_data["location_data"].each_with_object({}) do |item, result|
          result[item["id"]] = item["value"]
        end
    end
  end
end
