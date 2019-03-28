require "test_helper"

describe Gillbus::V2::Structs::Location do
  let(:raw_data) do
    JSON.parse(
      '{"id":1291,"default_name":"Vinnytsya","type_id":6,"subtype_id":8,"latitude":49.233118,"longitude":28.468231,"parent_id":1266,"deleted":false,"country_id":184,"timezone":"Europe/Kiev","date_modified":"2019-03-13T10:15:46.436391Z","location_data":[{"id":6,"value":"0510100000"},{"id":16,"value":"93FF9E8F723C60C3E040A8C01E02198C"},{"id":16,"value":"F339118E2F9AA947E040B85960522C04"}],"translations":[{"lang":"uk","name":"Вінниця","country_name":"Україна","region_name":"Вінницька обл."},{"lang":"en","name":"Vinnytsya","country_name":"Ukraine","region_name":"Vinnytsia obl."},{"lang":"ru","name":"Винница","country_name":"Украина","region_name":"Винницкая обл."},{"lang":"pl","name":"Winnica","country_name":"Ukraina","region_name":"Winnicki obw."}]}'
    )
  end
  let(:object) { Gillbus::V2::Structs::Location.from_raw_data(raw_data) }

  it "returns correct fields" do
    assert_equal 1291, object.id
    assert_equal 1266, object.parent_id
    assert_equal 184, object.country_id
    assert_equal 6, object.type_id
    assert_equal 8, object.sub_type_id
    assert_equal 49.233118, object.latitude
    assert_equal 28.468231, object.longitude
    assert_equal "Europe/Kiev", object.timezone
    assert_equal "Vinnytsya", object.default_name
    assert_equal false, object.deleted
    assert_equal(
      DateTime.parse("2019-03-13T10:15:46.436391Z"),
      object.date_modified,
    )
  end

  it "returns localized fields" do
    assert_equal(
      {
        "uk" => "Вінниця",
        "en" => "Vinnytsya",
        "ru" => "Винница",
        "pl" => "Winnica",
      },
      object.name,
    )
    assert_equal(
      {
        "uk" => "Вінницька обл.",
        "en" => "Vinnytsia obl.",
        "ru" => "Винницкая обл.",
        "pl" => "Winnicki obw.",
      },
      object.region_name,
    )
    assert_equal(
      {
        "uk" => "Україна",
        "en" => "Ukraine",
        "ru" => "Украина",
        "pl" => "Ukraina",
      },
      object.country_name,
    )
  end

  it "returns additional fields" do
    assert_equal(
      {
        6 => "0510100000",
        16 => "F339118E2F9AA947E040B85960522C04",
      },
      object.additional_fields,
    )
  end
end
