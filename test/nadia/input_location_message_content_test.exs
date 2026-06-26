defmodule Nadia.InputLocationMessageContentTest do
  use ExUnit.Case, async: true

  alias Nadia.InputLocationMessageContent

  test "builder emits location fields and omits nil options" do
    assert {:ok,
            %{
              latitude: 35.6762,
              longitude: 139.6503,
              horizontal_accuracy: 0,
              live_period: 0x7FFFFFFF,
              heading: 360,
              proximity_alert_radius: 1
            }} =
             InputLocationMessageContent.new(35.6762, 139.6503,
               horizontal_accuracy: 0,
               live_period: 0x7FFFFFFF,
               heading: 360,
               proximity_alert_radius: 1
             )
             |> InputLocationMessageContent.to_map()

    assert {:ok, %{latitude: 0, longitude: 0}} =
             InputLocationMessageContent.new(0, 0,
               horizontal_accuracy: nil,
               live_period: nil,
               heading: nil,
               proximity_alert_radius: nil
             )
             |> InputLocationMessageContent.to_map()
  end

  test "location accepts coordinate and option boundaries" do
    assert %InputLocationMessageContent{} =
             InputLocationMessageContent.new(-90, -180,
               horizontal_accuracy: 0,
               live_period: 60,
               heading: 1,
               proximity_alert_radius: 1
             )

    assert %InputLocationMessageContent{} =
             InputLocationMessageContent.new(90, 180,
               horizontal_accuracy: 1500,
               live_period: 86_400,
               heading: 360,
               proximity_alert_radius: 100_000
             )

    assert %InputLocationMessageContent{} =
             InputLocationMessageContent.new(0, 0, live_period: 0x7FFFFFFF)
  end

  test "location rejects out-of-range coordinates and options" do
    for {latitude, longitude} <- [{-90.01, 0}, {90.01, 0}, {0, -180.01}, {0, 180.01}] do
      assert_raise ArgumentError, ~r/must be a number from/, fn ->
        InputLocationMessageContent.new(latitude, longitude)
      end
    end

    for accuracy <- [-0.1, 1500.1, "near"] do
      assert_raise ArgumentError, ~r/horizontal_accuracy/, fn ->
        InputLocationMessageContent.new(0, 0, horizontal_accuracy: accuracy)
      end
    end

    for live_period <- [0, 59, 86_401, 1.5, "forever"] do
      assert_raise ArgumentError, ~r/live_period must be an integer/, fn ->
        InputLocationMessageContent.new(0, 0, live_period: live_period)
      end
    end

    for heading <- [0, 361, 1.5, "north"] do
      assert_raise ArgumentError, ~r/heading/, fn ->
        InputLocationMessageContent.new(0, 0, heading: heading)
      end
    end

    for radius <- [0, 100_001, 1.5, "near"] do
      assert_raise ArgumentError, ~r/proximity_alert_radius/, fn ->
        InputLocationMessageContent.new(0, 0, proximity_alert_radius: radius)
      end
    end
  end

  test "constructors reject unsupported options and malformed option containers" do
    assert_raise ArgumentError,
                 ~r/unsupported Nadia.InputLocationMessageContent option: :future/,
                 fn ->
                   InputLocationMessageContent.new(0, 0, future: true)
                 end

    for options <- [[:not_a_keyword], "near", nil] do
      assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
        InputLocationMessageContent.new(0, 0, options)
      end
    end
  end

  test "to_map returns deterministic errors for tampered opaque structs" do
    assert {:error, {:invalid_fields, :not_a_map}} =
             struct(InputLocationMessageContent, fields: :not_a_map)
             |> InputLocationMessageContent.to_map()

    assert {:error, {:unsupported_field, :future}} =
             struct(InputLocationMessageContent,
               fields: %{latitude: 0, longitude: 0, future: true}
             )
             |> InputLocationMessageContent.to_map()

    assert {:error, {:out_of_range, :latitude, 91, -90, 90}} =
             struct(InputLocationMessageContent, fields: %{latitude: 91, longitude: 0})
             |> InputLocationMessageContent.to_map()

    assert {:error, {:out_of_range, :live_period, 59, 60, 86_400}} =
             struct(InputLocationMessageContent,
               fields: %{latitude: 0, longitude: 0, live_period: 59}
             )
             |> InputLocationMessageContent.to_map()

    assert {:error, {:unsupported_field, :future}} =
             InputLocationMessageContent.new(0, 0)
             |> Map.put(:future, true)
             |> InputLocationMessageContent.to_map()

    assert {:error, :invalid_input_location_message_content} =
             InputLocationMessageContent.to_map(%{latitude: 0, longitude: 0})
  end

  test "unknown binary fields never create atoms" do
    option_key = "nadia_location_option_#{System.unique_integer([:positive, :monotonic])}"
    field_key = "nadia_location_field_#{System.unique_integer([:positive, :monotonic])}"
    wrapper_key = "nadia_location_wrapper_#{System.unique_integer([:positive, :monotonic])}"

    for key <- [option_key, field_key, wrapper_key] do
      refute existing_atom?(key)
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputLocationMessageContent option/, fn ->
      InputLocationMessageContent.new(0, 0, %{option_key => true})
    end

    assert {:error, {:unsupported_field, ^field_key}} =
             struct(InputLocationMessageContent,
               fields: %{field_key => true, latitude: 0, longitude: 0}
             )
             |> InputLocationMessageContent.to_map()

    assert {:error, {:unsupported_field, ^wrapper_key}} =
             InputLocationMessageContent.new(0, 0)
             |> Map.put(wrapper_key, true)
             |> InputLocationMessageContent.to_map()

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
