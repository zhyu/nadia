defmodule Nadia.InputVenueMessageContentTest do
  use ExUnit.Case, async: true

  alias Nadia.InputVenueMessageContent

  test "builder emits venue fields and omits nil provider options" do
    assert {:ok, venue} =
             InputVenueMessageContent.new(35.6762, 139.6503, "Nadia Cafe", "1 Bot Street",
               foursquare_id: "four-id",
               foursquare_type: nil,
               google_place_id: "google-id",
               google_place_type: "cafe"
             )
             |> InputVenueMessageContent.to_map()

    assert venue.latitude == 35.6762
    assert venue.longitude == 139.6503
    assert venue.title == "Nadia Cafe"
    assert venue.address == "1 Bot Street"
    assert venue.foursquare_id == "four-id"
    assert venue.google_place_id == "google-id"
    assert venue.google_place_type == "cafe"
    refute Map.has_key?(venue, :foursquare_type)
  end

  test "venue accepts coordinate boundaries" do
    assert %InputVenueMessageContent{} =
             InputVenueMessageContent.new(-90, -180, "South West", "Edge")

    assert %InputVenueMessageContent{} =
             InputVenueMessageContent.new(90, 180, "North East", "Edge")

    assert {:ok, %{foursquare_id: ""}} =
             InputVenueMessageContent.new(0, 0, "Title", "Address", foursquare_id: "")
             |> InputVenueMessageContent.to_map()
  end

  test "venue rejects out-of-range coordinates and invalid text" do
    for {latitude, longitude} <- [{-90.01, 0}, {90.01, 0}, {0, -180.01}, {0, 180.01}] do
      assert_raise ArgumentError, ~r/must be a number from/, fn ->
        InputVenueMessageContent.new(latitude, longitude, "Title", "Address")
      end
    end

    for {title, address, message} <- [
          {"", "Address", "title must be a non-empty"},
          {"Title", "", "address must be a non-empty"},
          {<<255>>, "Address", "title must be valid UTF-8"},
          {"Title", <<255>>, "address must be valid UTF-8"}
        ] do
      assert_raise ArgumentError, ~r/#{message}/, fn ->
        InputVenueMessageContent.new(0, 0, title, address)
      end
    end

    for field <- [:foursquare_id, :foursquare_type, :google_place_id, :google_place_type] do
      assert_raise ArgumentError, ~r/#{field} must be valid UTF-8/, fn ->
        InputVenueMessageContent.new(0, 0, "Title", "Address", [{field, <<255>>}])
      end
    end
  end

  test "constructors reject unsupported options and malformed option containers" do
    assert_raise ArgumentError,
                 ~r/unsupported Nadia.InputVenueMessageContent option: :future/,
                 fn ->
                   InputVenueMessageContent.new(0, 0, "Title", "Address", future: true)
                 end

    for options <- [[:not_a_keyword], "places", nil] do
      assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
        InputVenueMessageContent.new(0, 0, "Title", "Address", options)
      end
    end
  end

  test "to_map returns deterministic errors for tampered opaque structs" do
    assert {:error, {:invalid_fields, :not_a_map}} =
             struct(InputVenueMessageContent, fields: :not_a_map)
             |> InputVenueMessageContent.to_map()

    assert {:error, {:unsupported_field, :future}} =
             struct(InputVenueMessageContent,
               fields: %{latitude: 0, longitude: 0, title: "T", address: "A", future: true}
             )
             |> InputVenueMessageContent.to_map()

    assert {:error, {:out_of_range, :longitude, 181, -180, 180}} =
             struct(InputVenueMessageContent,
               fields: %{latitude: 0, longitude: 181, title: "T", address: "A"}
             )
             |> InputVenueMessageContent.to_map()

    assert {:error, {:required, :title}} =
             struct(InputVenueMessageContent,
               fields: %{latitude: 0, longitude: 0, title: "", address: "A"}
             )
             |> InputVenueMessageContent.to_map()

    assert {:error, {:invalid_utf8, :google_place_type}} =
             struct(InputVenueMessageContent,
               fields: %{
                 latitude: 0,
                 longitude: 0,
                 title: "T",
                 address: "A",
                 google_place_type: <<255>>
               }
             )
             |> InputVenueMessageContent.to_map()

    assert {:error, {:unsupported_field, :future}} =
             InputVenueMessageContent.new(0, 0, "Title", "Address")
             |> Map.put(:future, true)
             |> InputVenueMessageContent.to_map()

    assert {:error, :invalid_input_venue_message_content} =
             InputVenueMessageContent.to_map(%{latitude: 0, longitude: 0})
  end

  test "unknown binary fields never create atoms" do
    option_key = "nadia_venue_option_#{System.unique_integer([:positive, :monotonic])}"
    field_key = "nadia_venue_field_#{System.unique_integer([:positive, :monotonic])}"
    wrapper_key = "nadia_venue_wrapper_#{System.unique_integer([:positive, :monotonic])}"

    for key <- [option_key, field_key, wrapper_key] do
      refute existing_atom?(key)
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputVenueMessageContent option/, fn ->
      InputVenueMessageContent.new(0, 0, "Title", "Address", %{option_key => true})
    end

    assert {:error, {:unsupported_field, ^field_key}} =
             struct(InputVenueMessageContent,
               fields: %{field_key => true, latitude: 0, longitude: 0, title: "T", address: "A"}
             )
             |> InputVenueMessageContent.to_map()

    assert {:error, {:unsupported_field, ^wrapper_key}} =
             InputVenueMessageContent.new(0, 0, "Title", "Address")
             |> Map.put(wrapper_key, true)
             |> InputVenueMessageContent.to_map()

    for key <- [option_key, field_key, wrapper_key] do
      refute existing_atom?(key)
    end
  end

  defp existing_atom?(name) do
    _ = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end
end
