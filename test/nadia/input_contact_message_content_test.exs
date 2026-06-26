defmodule Nadia.InputContactMessageContentTest do
  use ExUnit.Case, async: true

  alias Nadia.InputContactMessageContent

  test "builder emits contact fields and omits nil options" do
    assert {:ok,
            %{
              phone_number: "+15550123",
              first_name: "Nadia",
              last_name: "Bot",
              vcard: "BEGIN:VCARD\nEND:VCARD"
            }} =
             InputContactMessageContent.new("+15550123", "Nadia",
               last_name: "Bot",
               vcard: "BEGIN:VCARD\nEND:VCARD"
             )
             |> InputContactMessageContent.to_map()

    assert {:ok, %{phone_number: "+15550123", first_name: "Nadia"}} =
             InputContactMessageContent.new("+15550123", "Nadia",
               last_name: nil,
               vcard: nil
             )
             |> InputContactMessageContent.to_map()
  end

  test "contact accepts vcard byte boundaries" do
    assert %InputContactMessageContent{} =
             InputContactMessageContent.new("+15550123", "Nadia", vcard: "")

    assert {:ok, %{last_name: ""}} =
             InputContactMessageContent.new("+15550123", "Nadia", last_name: "")
             |> InputContactMessageContent.to_map()

    vcard = String.duplicate("a", 2048)

    assert {:ok, %{vcard: ^vcard}} =
             InputContactMessageContent.new("+15550123", "Nadia", vcard: vcard)
             |> InputContactMessageContent.to_map()
  end

  test "contact rejects invalid text and vcard values" do
    for {phone_number, first_name, message} <- [
          {"", "Nadia", "phone_number must be a non-empty"},
          {<<255>>, "Nadia", "phone_number must be valid UTF-8"},
          {"+15550123", "", "first_name must be a non-empty"},
          {"+15550123", <<255>>, "first_name must be valid UTF-8"}
        ] do
      assert_raise ArgumentError, ~r/#{message}/, fn ->
        InputContactMessageContent.new(phone_number, first_name)
      end
    end

    assert_raise ArgumentError, ~r/last_name must be valid UTF-8/, fn ->
      InputContactMessageContent.new("+15550123", "Nadia", last_name: <<255>>)
    end

    assert_raise ArgumentError, ~r/vcard must be valid UTF-8 with 0 to 2048 bytes/, fn ->
      InputContactMessageContent.new("+15550123", "Nadia", vcard: String.duplicate("a", 2049))
    end

    assert_raise ArgumentError, ~r/vcard must be valid UTF-8/, fn ->
      InputContactMessageContent.new("+15550123", "Nadia", vcard: <<255>>)
    end
  end

  test "constructors reject unsupported options and malformed option containers" do
    assert_raise ArgumentError,
                 ~r/unsupported Nadia.InputContactMessageContent option: :future/,
                 fn ->
                   InputContactMessageContent.new("+15550123", "Nadia", future: true)
                 end

    for options <- [[:not_a_keyword], "contact", nil] do
      assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
        InputContactMessageContent.new("+15550123", "Nadia", options)
      end
    end
  end

  test "to_map returns deterministic errors for tampered opaque structs" do
    assert {:error, {:invalid_fields, :not_a_map}} =
             struct(InputContactMessageContent, fields: :not_a_map)
             |> InputContactMessageContent.to_map()

    assert {:error, {:unsupported_field, :future}} =
             struct(InputContactMessageContent,
               fields: %{phone_number: "+15550123", first_name: "Nadia", future: true}
             )
             |> InputContactMessageContent.to_map()

    assert {:error, {:required, :phone_number}} =
             struct(InputContactMessageContent, fields: %{phone_number: "", first_name: "Nadia"})
             |> InputContactMessageContent.to_map()

    assert {:error, {:invalid_utf8, :last_name}} =
             struct(InputContactMessageContent,
               fields: %{phone_number: "+15550123", first_name: "Nadia", last_name: <<255>>}
             )
             |> InputContactMessageContent.to_map()

    assert {:error, :invalid_vcard} =
             struct(InputContactMessageContent,
               fields: %{
                 phone_number: "+15550123",
                 first_name: "Nadia",
                 vcard: String.duplicate("a", 2049)
               }
             )
             |> InputContactMessageContent.to_map()

    assert {:error, {:unsupported_field, :future}} =
             InputContactMessageContent.new("+15550123", "Nadia")
             |> Map.put(:future, true)
             |> InputContactMessageContent.to_map()

    assert {:error, :invalid_input_contact_message_content} =
             InputContactMessageContent.to_map(%{phone_number: "+15550123"})
  end

  test "unknown binary fields never create atoms" do
    option_key = "nadia_contact_option_#{System.unique_integer([:positive, :monotonic])}"
    field_key = "nadia_contact_field_#{System.unique_integer([:positive, :monotonic])}"
    wrapper_key = "nadia_contact_wrapper_#{System.unique_integer([:positive, :monotonic])}"

    for key <- [option_key, field_key, wrapper_key] do
      refute existing_atom?(key)
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputContactMessageContent option/, fn ->
      InputContactMessageContent.new("+15550123", "Nadia", %{option_key => true})
    end

    assert {:error, {:unsupported_field, ^field_key}} =
             struct(InputContactMessageContent,
               fields: %{field_key => true, phone_number: "+15550123", first_name: "Nadia"}
             )
             |> InputContactMessageContent.to_map()

    assert {:error, {:unsupported_field, ^wrapper_key}} =
             InputContactMessageContent.new("+15550123", "Nadia")
             |> Map.put(wrapper_key, true)
             |> InputContactMessageContent.to_map()

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
