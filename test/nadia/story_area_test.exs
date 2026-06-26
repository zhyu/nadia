defmodule Nadia.StoryAreaTest do
  use ExUnit.Case, async: true

  alias Nadia.ReactionType
  alias Nadia.StoryArea

  defp position do
    StoryArea.position(50, 40.5, 20, 10.25, 90, 2)
  end

  test "position includes all fields and does not range-limit percentages" do
    assert {:ok,
            %{
              x_percentage: -25,
              y_percentage: 125,
              width_percentage: -1.5,
              height_percentage: 250,
              rotation_angle: 360,
              corner_radius_percentage: 150
            }} =
             StoryArea.position(-25, 125, -1.5, 250, 360, 150)
             |> StoryArea.to_map()

    assert %StoryArea{} = StoryArea.position(0, 0, 0, 0, 0, 0)
  end

  test "position requires six numeric values and limits rotation only" do
    values = [1, 2, 3, 4, 5, 6]

    for index <- 0..5 do
      invalid = List.replace_at(values, index, "number")

      assert_raise ArgumentError, ~r/must be a number/, fn ->
        apply(StoryArea, :position, invalid)
      end
    end

    for rotation <- [-0.1, 360.1] do
      assert_raise ArgumentError, ~r/rotation_angle must be a number from 0 to 360/, fn ->
        StoryArea.position(0, 0, 1, 1, rotation, 0)
      end
    end
  end

  test "location address includes every optional field and omits nil" do
    assert {:ok,
            %{
              country_code: "JP",
              state: "Tokyo",
              city: "Chiyoda",
              street: "1 Telegram Way"
            }} =
             StoryArea.location_address("JP",
               state: "Tokyo",
               city: "Chiyoda",
               street: "1 Telegram Way"
             )
             |> StoryArea.to_map()

    assert {:ok, %{country_code: "US", city: "Boston"}} =
             StoryArea.location_address("US", %{state: nil, city: "Boston", street: nil})
             |> StoryArea.to_map()
  end

  test "location nests its position, discriminator object, and optional address" do
    position = position()
    address = StoryArea.location_address("GB", city: "London")

    assert {:ok, area} =
             StoryArea.location(position, -90, 180, address: address)
             |> StoryArea.to_map()

    assert area.position == %{
             x_percentage: 50,
             y_percentage: 40.5,
             width_percentage: 20,
             height_percentage: 10.25,
             rotation_angle: 90,
             corner_radius_percentage: 2
           }

    assert area.type == %{
             type: "location",
             latitude: -90,
             longitude: 180,
             address: %{country_code: "GB", city: "London"}
           }

    assert {:ok, %{type: location_type}} =
             StoryArea.location(position, 90, -180, address: nil)
             |> StoryArea.to_map()

    refute Map.has_key?(location_type, :address)
  end

  test "suggested reaction covers all reaction variants, omits nil, and preserves false" do
    for {reaction, expected} <- [
          {ReactionType.emoji("🔥"), %{type: "emoji", emoji: "🔥"}},
          {ReactionType.custom_emoji("custom-id"),
           %{type: "custom_emoji", custom_emoji_id: "custom-id"}},
          {ReactionType.paid(), %{type: "paid"}}
        ] do
      assert {:ok,
              %{
                type: %{
                  type: "suggested_reaction",
                  reaction_type: ^expected,
                  is_dark: false,
                  is_flipped: false
                }
              }} =
               StoryArea.suggested_reaction(position(), reaction,
                 is_dark: false,
                 is_flipped: false
               )
               |> StoryArea.to_map()
    end

    assert {:ok, %{type: type}} =
             StoryArea.suggested_reaction(position(), ReactionType.emoji("👍"),
               is_dark: nil,
               is_flipped: nil
             )
             |> StoryArea.to_map()

    refute Map.has_key?(type, :is_dark)
    refute Map.has_key?(type, :is_flipped)
  end

  test "link, weather, and unique gift cover every area variant" do
    assert {:ok, %{type: %{type: "link", url: "https://example.test/story"}}} =
             StoryArea.link(position(), "https://example.test/story")
             |> StoryArea.to_map()

    assert {:ok, %{type: %{type: "link", url: "tg://resolve?domain=telegram"}}} =
             StoryArea.link(position(), "tg://resolve?domain=telegram")
             |> StoryArea.to_map()

    assert {:ok,
            %{
              type: %{
                type: "weather",
                temperature: -12.5,
                emoji: "❄️",
                background_color: 0xFFFFFFFF
              }
            }} =
             StoryArea.weather(position(), -12.5, "❄️", 0xFFFFFFFF)
             |> StoryArea.to_map()

    assert {:ok, %{type: %{type: "weather", background_color: 0}}} =
             StoryArea.weather(position(), 0, "☀️", 0)
             |> StoryArea.to_map()

    assert {:ok, %{type: %{type: "unique_gift", name: "Precious Peach-123"}}} =
             StoryArea.unique_gift(position(), "Precious Peach-123")
             |> StoryArea.to_map()
  end

  test "reaction builders require non-empty valid UTF-8 and paid has no fields" do
    assert {:ok, %{type: "emoji", emoji: "❤"}} =
             ReactionType.emoji("❤") |> ReactionType.to_map()

    assert {:ok, %{type: "custom_emoji", custom_emoji_id: "5368324170671202286"}} =
             ReactionType.custom_emoji("5368324170671202286")
             |> ReactionType.to_map()

    assert {:ok, %{type: "paid"}} = ReactionType.paid() |> ReactionType.to_map()

    for builder <- [&ReactionType.emoji/1, &ReactionType.custom_emoji/1],
        invalid <- ["", <<255>>, nil, :emoji] do
      assert_raise ArgumentError, ~r/valid UTF-8/, fn -> builder.(invalid) end
    end
  end

  test "location validates conventional geographic coordinate ranges" do
    assert %StoryArea{} = StoryArea.location(position(), -90, -180)
    assert %StoryArea{} = StoryArea.location(position(), 90.0, 180.0)

    for {latitude, longitude} <- [
          {-90.01, 0},
          {90.01, 0},
          {0, -180.01},
          {0, 180.01},
          {"0", 0},
          {0, "0"}
        ] do
      assert_raise ArgumentError, ~r/must be a number from/, fn ->
        StoryArea.location(position(), latitude, longitude)
      end
    end
  end

  test "address validates country code and optional UTF-8 strings" do
    for country_code <- ["us", "USA", "U", "U1", "ÅS", "", nil] do
      assert_raise ArgumentError, ~r/two uppercase ASCII letters/, fn ->
        StoryArea.location_address(country_code, [])
      end
    end

    for field <- [:state, :city, :street],
        invalid <- ["", <<255>>, 1, false] do
      assert_raise ArgumentError, ~r/(valid UTF-8|must be valid UTF-8)/, fn ->
        StoryArea.location_address("US", [{field, invalid}])
      end
    end
  end

  test "links require valid supported URIs with a target" do
    for valid <- [
          "http://example.test",
          "https://example.test/path?query=1",
          "tg://user?id=123",
          "tg:///resolve",
          "TG://resolve"
        ] do
      assert %StoryArea{} = StoryArea.link(position(), valid)
    end

    for invalid <- [
          "",
          "example.test",
          "ftp://example.test/file",
          "https:///missing-host",
          "https://exa mple.test",
          "tg://",
          "tg:///",
          "tg://?domain=telegram",
          <<255>>
        ] do
      assert_raise ArgumentError, ~r/HTTP or HTTPS with a host, or tg:\/\/ with a target/, fn ->
        StoryArea.link(position(), invalid)
      end
    end
  end

  test "suggested reactions require typed reactions and boolean options" do
    assert_raise ArgumentError, ~r/reaction must be a Nadia.ReactionType/, fn ->
      StoryArea.suggested_reaction(position(), %{type: "emoji", emoji: "👍"})
    end

    for {field, value} <- [is_dark: 0, is_flipped: "false"] do
      assert_raise ArgumentError, ~r/#{field} must be a boolean/, fn ->
        StoryArea.suggested_reaction(position(), ReactionType.emoji("👍"), [{field, value}])
      end
    end
  end

  test "weather validates temperature, emoji, and full ARGB boundaries" do
    for temperature <- [-100, -0.5, 0, 42.25] do
      assert %StoryArea{} = StoryArea.weather(position(), temperature, "🌡️", 0xAABBCCDD)
    end

    for invalid <- ["20", nil, false] do
      assert_raise ArgumentError, ~r/temperature must be a number/, fn ->
        StoryArea.weather(position(), invalid, "☀️", 0)
      end
    end

    for invalid <- ["", <<255>>, nil] do
      assert_raise ArgumentError, ~r/(valid UTF-8|must be valid UTF-8)/, fn ->
        StoryArea.weather(position(), 20, invalid, 0)
      end
    end

    for invalid <- [-1, 0x1_0000_0000, 1.5, "0"] do
      assert_raise ArgumentError, ~r/ARGB integer from 0 to 4294967295/, fn ->
        StoryArea.weather(position(), 20, "☀️", invalid)
      end
    end
  end

  test "gift name is only required to be a non-empty valid UTF-8 string" do
    for valid <- ["x", "gift with spaces", "贈り物/№1", "no-invented-syntax!"] do
      assert %StoryArea{} = StoryArea.unique_gift(position(), valid)
    end

    for invalid <- ["", <<255>>, nil, 123] do
      assert_raise ArgumentError, ~r/(valid UTF-8|must be valid UTF-8)/, fn ->
        StoryArea.unique_gift(position(), invalid)
      end
    end
  end

  test "constructors require typed positions and validate option containers" do
    assert_raise ArgumentError, ~r/position must be built with/, fn ->
      StoryArea.link(%{x_percentage: 50}, "https://example.test")
    end

    assert_raise ArgumentError, ~r/address must be built with/, fn ->
      StoryArea.location(position(), 0, 0, address: %{country_code: "US"})
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.StoryArea option/, fn ->
      StoryArea.location(position(), 0, 0, future: true)
    end

    assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
      StoryArea.location_address("US", [:not_a_keyword])
    end
  end

  test "to_map rejects tampered opaque StoryArea values" do
    assert {:error, {:invalid_discriminator, :future}} =
             struct(StoryArea, variant: :future, fields: %{})
             |> StoryArea.to_map()

    assert {:error, {:invalid_fields, :not_a_map}} =
             struct(StoryArea, variant: :position, fields: :not_a_map)
             |> StoryArea.to_map()

    assert {:error, {:unsupported_field, :future}} =
             struct(StoryArea,
               variant: :position,
               fields: %{
                 x_percentage: 0,
                 y_percentage: 0,
                 width_percentage: 1,
                 height_percentage: 1,
                 rotation_angle: 0,
                 corner_radius_percentage: 0,
                 future: true
               }
             )
             |> StoryArea.to_map()

    assert {:error, {:number_required, :height_percentage}} =
             struct(StoryArea,
               variant: :position,
               fields: %{
                 x_percentage: 0,
                 y_percentage: 0,
                 width_percentage: 1,
                 rotation_angle: 0,
                 corner_radius_percentage: 0
               }
             )
             |> StoryArea.to_map()

    malformed_position =
      struct(StoryArea,
        variant: :position,
        fields: %{
          x_percentage: 0,
          y_percentage: 0,
          width_percentage: 1,
          height_percentage: 1,
          rotation_angle: 361,
          corner_radius_percentage: 0
        }
      )

    assert {:error, {:out_of_range, :rotation_angle, 361, 0, 360}} =
             struct(StoryArea,
               variant: :link,
               fields: %{position: malformed_position, url: "https://example.test"}
             )
             |> StoryArea.to_map()

    malformed_address =
      struct(StoryArea, variant: :location_address, fields: %{country_code: "us"})

    assert {:error, {:invalid_country_code, "us"}} =
             struct(StoryArea,
               variant: :location,
               fields: %{
                 position: position(),
                 latitude: 0,
                 longitude: 0,
                 address: malformed_address
               }
             )
             |> StoryArea.to_map()
  end

  test "to_map rejects tampered opaque ReactionType values and nested reactions" do
    assert {:error, {:invalid_discriminator, :future}} =
             struct(ReactionType, variant: :future, fields: %{})
             |> ReactionType.to_map()

    assert {:error, {:invalid_fields, nil}} =
             struct(ReactionType, variant: :emoji, fields: nil)
             |> ReactionType.to_map()

    assert {:error, {:unsupported_field, :emoji}} =
             struct(ReactionType, variant: :paid, fields: %{emoji: "👍"})
             |> ReactionType.to_map()

    assert {:error, {:required, :custom_emoji_id}} =
             struct(ReactionType, variant: :custom_emoji, fields: %{})
             |> ReactionType.to_map()

    malformed = struct(ReactionType, variant: :emoji, fields: %{emoji: <<255>>})

    assert {:error, :invalid_utf8} = ReactionType.to_map(malformed)

    assert {:error, :invalid_utf8} =
             struct(StoryArea,
               variant: :suggested_reaction,
               fields: %{position: position(), reaction_type: malformed}
             )
             |> StoryArea.to_map()
  end

  test "validate_areas enforces every typed per-variant boundary" do
    variants = [
      {StoryArea.location(position(), 0, 0), 10, :location},
      {StoryArea.suggested_reaction(position(), ReactionType.emoji("👍")), 5, :suggested_reaction},
      {StoryArea.link(position(), "https://example.test"), 3, :link},
      {StoryArea.weather(position(), 20, "☀️", 0), 3, :weather},
      {StoryArea.unique_gift(position(), "gift"), 1, :unique_gift}
    ]

    for {area, limit, variant} <- variants do
      assert :ok = StoryArea.validate_areas(List.duplicate(area, limit))

      assert {:error, {:area_count, ^variant, count, ^limit}} =
               StoryArea.validate_areas(List.duplicate(area, limit + 1))

      assert count == limit + 1
    end
  end

  test "validate_areas preserves raw compatibility and validates typed members in mixed lists" do
    raw = %{position: %{x_percentage: "raw"}, type: %{type: "future"}}
    typed = StoryArea.link(position(), "https://example.test")

    assert :ok = StoryArea.validate_areas([])
    assert :ok = StoryArea.validate_areas([raw])
    assert :ok = StoryArea.validate_areas(List.duplicate(raw, 20))
    assert :ok = StoryArea.validate_areas(:raw)
    assert :ok = StoryArea.validate_areas([typed, raw])

    assert :ok =
             StoryArea.validate_areas([
               typed,
               raw,
               raw,
               raw,
               StoryArea.link(position(), "tg://user?id=1")
             ])

    malformed =
      struct(StoryArea,
        variant: :weather,
        fields: %{
          position: position(),
          temperature: 20,
          emoji: "☀️",
          background_color: -1
        }
      )

    assert {:error, {:invalid_argb, -1}} =
             StoryArea.validate_areas([raw, typed, malformed])

    assert {:error, {:invalid_area_variant, :position}} =
             StoryArea.validate_areas([raw, position()])
  end

  test "user-controlled strings and option keys never create atoms" do
    suffix = Integer.to_string(System.unique_integer([:positive]))
    unknown_key = "nadia_story_area_option_" <> suffix
    country_code = "nadia_story_area_country_" <> suffix
    reaction = "nadia_story_area_reaction_" <> suffix

    for value <- [unknown_key, country_code, reaction] do
      assert_raise ArgumentError, fn -> String.to_existing_atom(value) end
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.StoryArea option/, fn ->
      StoryArea.location(position(), 0, 0, %{unknown_key => true})
    end

    assert_raise ArgumentError, ~r/two uppercase ASCII letters/, fn ->
      StoryArea.location_address(country_code, [])
    end

    assert %ReactionType{} = ReactionType.emoji(reaction)

    for value <- [unknown_key, country_code, reaction] do
      assert_raise ArgumentError, fn -> String.to_existing_atom(value) end
    end
  end
end
