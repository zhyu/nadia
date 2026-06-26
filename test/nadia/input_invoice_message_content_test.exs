defmodule Nadia.InputInvoiceMessageContentTest do
  use ExUnit.Case, async: true

  alias Nadia.InputInvoiceMessageContent
  alias Nadia.LabeledPrice

  test "constructor covers official fields, encodes provider data, omits nil, and preserves false" do
    content =
      InputInvoiceMessageContent.new(
        "Nadia invoice",
        "Typed invoice content",
        "payload-123",
        "USD",
        [
          LabeledPrice.new("Base", 1500),
          %{"label" => "Tax", "amount" => 125}
        ],
        provider_token: "provider-token",
        max_tip_amount: 500,
        suggested_tip_amounts: [100, 250],
        provider_data: %{order_id: "order-1", nested: %{coupon: nil, gift: false}},
        photo_url: "https://cdn.example.test/invoice.jpg",
        photo_size: 0,
        photo_width: 640,
        photo_height: 480,
        need_name: false,
        need_phone_number: true,
        need_email: false,
        need_shipping_address: true,
        send_phone_number_to_provider: false,
        send_email_to_provider: true,
        is_flexible: false
      )

    assert {:ok, invoice} = InputInvoiceMessageContent.to_map(content)

    assert invoice.title == "Nadia invoice"
    assert invoice.payload == "payload-123"
    assert invoice.provider_token == "provider-token"
    assert invoice.photo_size == 0
    assert invoice.need_name == false
    assert invoice.need_email == false
    assert invoice.send_phone_number_to_provider == false
    assert invoice.is_flexible == false

    assert invoice.prices == [
             %{label: "Base", amount: 1500},
             %{label: "Tax", amount: 125}
           ]

    assert Jason.decode!(invoice.provider_data) == %{
             "order_id" => "order-1",
             "nested" => %{"gift" => false}
           }

    assert {:ok, without_nil_options} =
             InputInvoiceMessageContent.new(
               "No nils",
               "Nil options omitted",
               "payload",
               "USD",
               [LabeledPrice.new("Base", 100)],
               photo_url: nil,
               need_name: nil
             )
             |> InputInvoiceMessageContent.to_map()

    refute Map.has_key?(without_nil_options, :photo_url)
    refute Map.has_key?(without_nil_options, :need_name)
  end

  test "required field boundaries follow official invoice limits" do
    assert {:ok, %{title: "a", description: "b", payload: "c"}} =
             InputInvoiceMessageContent.new(
               "a",
               "b",
               "c",
               "USD",
               [LabeledPrice.new("Base", 100)]
             )
             |> InputInvoiceMessageContent.to_map()

    assert {:ok, _invoice} =
             InputInvoiceMessageContent.new(
               String.duplicate("t", 32),
               String.duplicate("d", 255),
               String.duplicate("p", 128),
               "USD",
               [LabeledPrice.new("Base", 100)]
             )
             |> InputInvoiceMessageContent.to_map()

    for {field, value} <- [
          title: "",
          title: String.duplicate("t", 33),
          description: "",
          description: String.duplicate("d", 256),
          payload: "",
          payload: String.duplicate("p", 129)
        ] do
      fields = valid_fields(%{field => value})

      assert {:error, {:invalid_string, ^field, _range, _unit}} =
               struct(InputInvoiceMessageContent, fields: fields)
               |> InputInvoiceMessageContent.to_map()
    end

    assert {:error, {:required, :currency}} =
             struct(InputInvoiceMessageContent, fields: Map.delete(valid_fields(), :currency))
             |> InputInvoiceMessageContent.to_map()

    assert {:error, {:required, :prices}} =
             struct(InputInvoiceMessageContent, fields: Map.delete(valid_fields(), :prices))
             |> InputInvoiceMessageContent.to_map()
  end

  test "price list boundaries and amount validation fail before HTTP integration" do
    assert {:error, {:prices_size, 0}} =
             struct(InputInvoiceMessageContent, fields: valid_fields(%{prices: []}))
             |> InputInvoiceMessageContent.to_map()

    assert {:error, {:invalid_prices, :not_a_list}} =
             struct(InputInvoiceMessageContent, fields: valid_fields(%{prices: :not_a_list}))
             |> InputInvoiceMessageContent.to_map()

    assert {:error, {:price, 0, {:invalid_amount, 1.5}}} =
             struct(
               InputInvoiceMessageContent,
               fields: valid_fields(%{prices: [%{label: "Bad", amount: 1.5}]})
             )
             |> InputInvoiceMessageContent.to_map()

    assert {:error, {:price, 0, {:required, :label}}} =
             struct(
               InputInvoiceMessageContent,
               fields: valid_fields(%{prices: [%{amount: 100}]})
             )
             |> InputInvoiceMessageContent.to_map()
  end

  test "Stars constructor and XTR edge cases are validated" do
    assert {:ok, invoice} =
             InputInvoiceMessageContent.stars(
               "Stars",
               "One price",
               "stars-payload",
               LabeledPrice.new("Stars", 50),
               need_email: false
             )
             |> InputInvoiceMessageContent.to_map()

    assert invoice.currency == "XTR"
    assert invoice.provider_token == ""
    assert invoice.prices == [%{label: "Stars", amount: 50}]
    assert invoice.need_email == false

    assert {:error, {:xtr_prices_size, 2}} =
             struct(
               InputInvoiceMessageContent,
               fields:
                 valid_fields(%{
                   currency: "XTR",
                   prices: [
                     LabeledPrice.new("One", 1),
                     LabeledPrice.new("Two", 2)
                   ]
                 })
             )
             |> InputInvoiceMessageContent.to_map()

    assert {:error, {:xtr_provider_token, "provider-token"}} =
             struct(
               InputInvoiceMessageContent,
               fields: valid_fields(%{currency: "XTR", provider_token: "provider-token"})
             )
             |> InputInvoiceMessageContent.to_map()

    assert {:error, {:xtr_unsupported_field, :max_tip_amount}} =
             struct(
               InputInvoiceMessageContent,
               fields: valid_fields(%{currency: "XTR", max_tip_amount: 1})
             )
             |> InputInvoiceMessageContent.to_map()
  end

  test "tip amount rules are enforced locally" do
    assert {:ok, %{suggested_tip_amounts: []}} =
             struct(
               InputInvoiceMessageContent,
               fields: valid_fields(%{max_tip_amount: 0, suggested_tip_amounts: []})
             )
             |> InputInvoiceMessageContent.to_map()

    for {overrides, expected} <- [
          {%{suggested_tip_amounts: [100]}, {:suggested_tip_amounts, :max_tip_amount_required}},
          {%{max_tip_amount: 500, suggested_tip_amounts: [0]},
           {:suggested_tip_amounts, :positive_integers_required}},
          {%{max_tip_amount: 500, suggested_tip_amounts: [100, 100]},
           {:suggested_tip_amounts, :not_strictly_increasing}},
          {%{max_tip_amount: 500, suggested_tip_amounts: [100, 200, 300, 400, 500]},
           {:suggested_tip_amounts, {:too_many, 5}}},
          {%{max_tip_amount: 500, suggested_tip_amounts: [100, 600]},
           {:suggested_tip_amounts, {:exceeds_max_tip_amount, 600, 500}}}
        ] do
      assert {:error, ^expected} =
               struct(InputInvoiceMessageContent, fields: valid_fields(overrides))
               |> InputInvoiceMessageContent.to_map()
    end
  end

  test "optional field validation covers booleans, integers, URLs, currency, and options" do
    for {overrides, expected} <- [
          {%{need_email: "false"}, {:invalid_boolean, :need_email, "false"}},
          {%{photo_size: -1}, {:invalid_non_negative_integer, :photo_size, -1}},
          {%{photo_width: 1.5}, {:invalid_non_negative_integer, :photo_width, 1.5}},
          {%{photo_url: "ftp://cdn.example.test/invoice.jpg"},
           {:invalid_url, :photo_url, "ftp://cdn.example.test/invoice.jpg"}},
          {%{currency: "usd"}, {:invalid_currency, "usd"}}
        ] do
      assert {:error, ^expected} =
               struct(InputInvoiceMessageContent, fields: valid_fields(overrides))
               |> InputInvoiceMessageContent.to_map()
    end

    assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
      InputInvoiceMessageContent.new("Title", "Description", "payload", "USD", [], [
        :not_a_keyword
      ])
    end

    unknown_key = "invoice_option_unknown_#{System.unique_integer([:positive, :monotonic])}"
    refute existing_atom?(unknown_key)

    assert_raise ArgumentError, ~r/unsupported Nadia.InputInvoiceMessageContent option/, fn ->
      InputInvoiceMessageContent.new(
        "Title",
        "Description",
        "payload",
        "USD",
        [LabeledPrice.new("Base", 100)],
        %{unknown_key => true}
      )
    end

    refute existing_atom?(unknown_key)
  end

  test "malformed typed structs return error tuples from to_map" do
    assert {:error, {:invalid_fields, :not_a_map}} =
             struct(InputInvoiceMessageContent, fields: :not_a_map)
             |> InputInvoiceMessageContent.to_map()

    assert {:error, {:unsupported_field, :future}} =
             struct(InputInvoiceMessageContent, fields: valid_fields(%{future: false}))
             |> InputInvoiceMessageContent.to_map()

    malformed_price = struct(LabeledPrice, fields: %{label: "Base", amount: "100"})

    assert {:error, {:price, 0, {:invalid_amount, "100"}}} =
             struct(InputInvoiceMessageContent,
               fields: valid_fields(%{prices: [malformed_price]})
             )
             |> InputInvoiceMessageContent.to_map()
  end

  test "raw price maps with string keys do not create atoms" do
    unknown_key = "invoice_price_unknown_#{System.unique_integer([:positive, :monotonic])}"
    refute existing_atom?(unknown_key)

    assert {:ok, %{prices: [%{label: "Raw", amount: 100}]}} =
             InputInvoiceMessageContent.new(
               "Title",
               "Description",
               "payload",
               "USD",
               [%{"label" => "Raw", "amount" => 100, unknown_key => false}]
             )
             |> InputInvoiceMessageContent.to_map()

    refute existing_atom?(unknown_key)
  end

  defp valid_fields(overrides \\ %{}) do
    Map.merge(
      %{
        title: "Title",
        description: "Description",
        payload: "payload",
        currency: "USD",
        prices: [LabeledPrice.new("Base", 100)]
      },
      overrides
    )
  end

  defp existing_atom?(name) do
    _atom = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end
end
