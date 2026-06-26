defmodule Nadia.LabeledPriceTest do
  use ExUnit.Case, async: true

  alias Nadia.LabeledPrice

  defmodule PriceStruct do
    defstruct [:label, :amount]
  end

  test "constructor and to_map preserve integer amounts" do
    assert {:ok, %{label: "Base", amount: 145}} =
             "Base"
             |> LabeledPrice.new(145)
             |> LabeledPrice.to_map()

    assert {:ok, %{label: "Discount", amount: -25}} =
             "Discount"
             |> LabeledPrice.new(-25)
             |> LabeledPrice.to_map()
  end

  test "constructor rejects invalid label and amount values" do
    assert_raise ArgumentError, ~r/label is required/, fn ->
      LabeledPrice.new(nil, 100)
    end

    for label <- [12, <<255>>] do
      assert_raise ArgumentError, ~r/label must be a valid UTF-8 binary/, fn ->
        LabeledPrice.new(label, 100)
      end
    end

    for amount <- [1.5, "100", nil] do
      assert_raise ArgumentError, ~r/amount.*integer|amount is required/, fn ->
        LabeledPrice.new("Base", amount)
      end
    end
  end

  test "normalize accepts raw keyword lists, maps, and structs without atomizing string keys" do
    unknown_key = "labeled_price_unknown_#{System.unique_integer([:positive, :monotonic])}"
    refute existing_atom?(unknown_key)

    assert {:ok, %{label: "Keyword", amount: 100}} =
             LabeledPrice.normalize(label: "Keyword", amount: 100)

    assert {:ok, %{label: "String keys", amount: 200}} =
             LabeledPrice.normalize(%{
               "label" => "String keys",
               "amount" => 200,
               unknown_key => false
             })

    assert {:ok, %{label: "Struct", amount: 300}} =
             LabeledPrice.normalize(%PriceStruct{label: "Struct", amount: 300})

    refute existing_atom?(unknown_key)
  end

  test "to_map returns deterministic errors for malformed typed structs" do
    assert {:error, {:invalid_fields, :not_a_map}} =
             struct(LabeledPrice, fields: :not_a_map)
             |> LabeledPrice.to_map()

    assert {:error, {:unsupported_field, :future}} =
             struct(LabeledPrice, fields: %{label: "Base", amount: 100, future: false})
             |> LabeledPrice.to_map()

    assert {:error, {:required, :label}} =
             struct(LabeledPrice, fields: %{amount: 100})
             |> LabeledPrice.to_map()

    assert {:error, {:invalid_amount, 1.5}} =
             struct(LabeledPrice, fields: %{label: "Base", amount: 1.5})
             |> LabeledPrice.to_map()
  end

  defp existing_atom?(name) do
    _atom = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end
end
