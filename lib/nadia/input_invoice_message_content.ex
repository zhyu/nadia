defmodule Nadia.InputInvoiceMessageContent do
  @moduledoc """
  Typed builder for Telegram `InputInvoiceMessageContent` objects.

  The builder validates only constraints that are knowable before calling
  Telegram: required string lengths, integer money fields, price-list shape,
  tip ordering, booleans, photo URL shape, and Telegram Stars (`XTR`) rules
  documented for invoice content. Provider-specific and currency-specific
  payment validation remains Telegram's responsibility.
  """

  alias Nadia.LabeledPrice

  @enforce_keys [:fields]
  defstruct [:fields]

  @typedoc "A typed Telegram InputInvoiceMessageContent value. Its representation is opaque."
  @opaque t :: %__MODULE__{fields: map}

  @type options :: keyword | map
  @type price :: LabeledPrice.t() | LabeledPrice.raw()

  @optional_fields [
    :provider_token,
    :max_tip_amount,
    :suggested_tip_amounts,
    :provider_data,
    :photo_url,
    :photo_size,
    :photo_width,
    :photo_height,
    :need_name,
    :need_phone_number,
    :need_email,
    :need_shipping_address,
    :send_phone_number_to_provider,
    :send_email_to_provider,
    :is_flexible
  ]

  @required_fields [:title, :description, :payload, :currency, :prices]
  @allowed_fields @required_fields ++ @optional_fields
  @boolean_fields [
    :need_name,
    :need_phone_number,
    :need_email,
    :need_shipping_address,
    :send_phone_number_to_provider,
    :send_email_to_provider,
    :is_flexible
  ]
  @integer_fields [:max_tip_amount, :photo_size, :photo_width, :photo_height]

  @doc """
  Builds an invoice message content object.

  Supported options are the optional fields from Telegram
  `InputInvoiceMessageContent`. Options whose value is `nil` are omitted.
  """
  @spec new(binary, binary, binary, binary, [price], options) :: t
  def new(title, description, payload, currency, prices, options \\ []) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(
        %{
          title: title,
          description: description,
          payload: payload,
          currency: currency,
          prices: prices
        },
        fn {key, value}, fields ->
          if key in @optional_fields do
            if is_nil(value), do: fields, else: Map.put(fields, key, value)
          else
            raise ArgumentError,
                  "unsupported Nadia.InputInvoiceMessageContent option: #{inspect(key)}"
          end
        end
      )

    build(fields)
  end

  @doc """
  Builds Telegram Stars (`XTR`) invoice message content.

  The price argument can be a single price object or a one-item list. The
  builder includes an empty `provider_token`, as documented for Stars payments.
  """
  @spec stars(binary, binary, binary, price | [price], options) :: t
  def stars(title, description, payload, price, options \\ []) do
    options =
      options
      |> normalize_options!()
      |> put_new_option(:provider_token, "")

    new(title, description, payload, "XTR", normalize_star_prices(price), options)
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{fields: fields}) do
    with :ok <- validate_fields_map(fields),
         :ok <- validate_allowed_fields(fields),
         :ok <- validate_required_strings(fields),
         :ok <- validate_currency(Map.get(fields, :currency)),
         {:ok, prices} <- validate_prices(Map.get(fields, :prices), Map.get(fields, :currency)),
         :ok <- validate_provider_token(fields),
         :ok <- validate_optional_strings(fields),
         {:ok, provider_data} <- normalize_provider_data(Map.get(fields, :provider_data)),
         :ok <- validate_integer_fields(fields),
         :ok <- validate_boolean_fields(fields),
         :ok <- validate_tips(fields) do
      fields =
        fields
        |> Map.put(:prices, prices)
        |> put_normalized_provider_data(provider_data)
        |> reject_nil_values()

      {:ok, fields}
    end
  end

  def to_map(_content), do: {:error, :invalid_input_invoice_message_content}

  defp build(fields) do
    content = %__MODULE__{fields: fields}

    case to_map(content) do
      {:ok, _map} -> content
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  defp normalize_options!(options) when is_map(options), do: Map.to_list(options)

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError,
            "Nadia.InputInvoiceMessageContent options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do:
      raise(
        ArgumentError,
        "Nadia.InputInvoiceMessageContent options must be a keyword list or map"
      )

  defp put_new_option(options, key, value) do
    if Keyword.has_key?(options, key), do: options, else: Keyword.put(options, key, value)
  end

  defp normalize_star_prices(prices) when is_list(prices) do
    if Keyword.keyword?(prices), do: [prices], else: prices
  end

  defp normalize_star_prices(price), do: [price]

  defp validate_fields_map(fields) when is_map(fields), do: :ok
  defp validate_fields_map(fields), do: {:error, {:invalid_fields, fields}}

  defp validate_allowed_fields(fields) do
    case fields
         |> Map.keys()
         |> Enum.sort()
         |> Enum.find(&(&1 not in @allowed_fields)) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_required_strings(fields) do
    with :ok <- validate_sized_string(fields[:title], :title, 1..32, :characters),
         :ok <- validate_sized_string(fields[:description], :description, 1..255, :characters),
         :ok <- validate_sized_string(fields[:payload], :payload, 1..128, :bytes) do
      :ok
    end
  end

  defp validate_sized_string(nil, field, _range, _unit), do: {:error, {:required, field}}

  defp validate_sized_string(value, field, range, :characters) when is_binary(value) do
    if String.valid?(value) and String.length(value) in range do
      :ok
    else
      {:error, {:invalid_string, field, range, :characters}}
    end
  end

  defp validate_sized_string(value, field, range, :bytes) when is_binary(value) do
    if String.valid?(value) and byte_size(value) in range do
      :ok
    else
      {:error, {:invalid_string, field, range, :bytes}}
    end
  end

  defp validate_sized_string(_value, field, range, unit),
    do: {:error, {:invalid_string, field, range, unit}}

  defp validate_currency(nil), do: {:error, {:required, :currency}}

  defp validate_currency(currency) when is_binary(currency) do
    if Regex.match?(~r/\A[A-Z]{3}\z/, currency) do
      :ok
    else
      {:error, {:invalid_currency, currency}}
    end
  end

  defp validate_currency(currency), do: {:error, {:invalid_currency, currency}}

  defp validate_prices(nil, _currency), do: {:error, {:required, :prices}}
  defp validate_prices([], _currency), do: {:error, {:prices_size, 0}}

  defp validate_prices(prices, currency) when is_list(prices) do
    with :ok <- validate_xtr_prices_size(prices, currency),
         {:ok, prices} <- normalize_prices(prices) do
      {:ok, prices}
    end
  end

  defp validate_prices(prices, _currency), do: {:error, {:invalid_prices, prices}}

  defp validate_xtr_prices_size(prices, "XTR") do
    if length(prices) == 1, do: :ok, else: {:error, {:xtr_prices_size, length(prices)}}
  end

  defp validate_xtr_prices_size(_prices, _currency), do: :ok

  defp normalize_prices(prices) do
    prices
    |> Enum.with_index()
    |> Enum.reduce_while({:ok, []}, fn {price, index}, {:ok, prices} ->
      case LabeledPrice.normalize(price) do
        {:ok, price} -> {:cont, {:ok, [price | prices]}}
        {:error, reason} -> {:halt, {:error, {:price, index, reason}}}
      end
    end)
    |> case do
      {:ok, prices} -> {:ok, Enum.reverse(prices)}
      error -> error
    end
  end

  defp validate_provider_token(%{currency: "XTR", provider_token: token})
       when is_binary(token) do
    if token == "", do: :ok, else: {:error, {:xtr_provider_token, token}}
  end

  defp validate_provider_token(%{currency: "XTR", provider_token: _token}) do
    {:error, {:invalid_string, :provider_token, :any, :characters}}
  end

  defp validate_provider_token(%{provider_token: token}),
    do: validate_optional_binary(token, :provider_token)

  defp validate_provider_token(_fields), do: :ok

  defp validate_optional_strings(fields) do
    with :ok <- validate_optional_binary(Map.get(fields, :photo_url), :photo_url),
         :ok <- validate_photo_url(Map.get(fields, :photo_url)) do
      :ok
    end
  end

  defp validate_optional_binary(nil, _field), do: :ok

  defp validate_optional_binary(value, _field) when is_binary(value) do
    if String.valid?(value), do: :ok, else: {:error, :invalid_utf8}
  end

  defp validate_optional_binary(_value, field),
    do: {:error, {:invalid_string, field, :any, :characters}}

  defp validate_photo_url(nil), do: :ok

  defp validate_photo_url(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host}
      when scheme in ["http", "https"] and is_binary(host) and byte_size(host) > 0 ->
        :ok

      _other ->
        {:error, {:invalid_url, :photo_url, url}}
    end
  end

  defp normalize_provider_data(nil), do: {:ok, nil}

  defp normalize_provider_data(data) when is_binary(data) do
    if String.valid?(data),
      do: {:ok, data},
      else: {:error, {:invalid_provider_data, :invalid_utf8}}
  end

  defp normalize_provider_data(data) do
    data
    |> json_payload_value()
    |> Jason.encode()
    |> case do
      {:ok, encoded} -> {:ok, encoded}
      {:error, error} -> {:error, {:invalid_provider_data, error}}
    end
  rescue
    error -> {:error, {:invalid_provider_data, error}}
  end

  defp json_payload_value(value) when is_list(value) do
    if Keyword.keyword?(value) do
      value
      |> Map.new()
      |> json_payload_value()
    else
      Enum.map(value, &json_payload_value/1)
    end
  end

  defp json_payload_value(%_{} = value) do
    value
    |> Map.from_struct()
    |> json_payload_value()
  end

  defp json_payload_value(value) when is_map(value) do
    value
    |> reject_nil_values()
    |> Map.new(fn {key, value} -> {key, json_payload_value(value)} end)
  end

  defp json_payload_value(value), do: value

  defp put_normalized_provider_data(fields, nil), do: fields

  defp put_normalized_provider_data(fields, provider_data),
    do: Map.put(fields, :provider_data, provider_data)

  defp validate_integer_fields(fields) do
    Enum.reduce_while(@integer_fields, :ok, fn field, :ok ->
      if Map.has_key?(fields, field) do
        case Map.get(fields, field) do
          value when is_integer(value) and value >= 0 -> {:cont, :ok}
          value -> {:halt, {:error, {:invalid_non_negative_integer, field, value}}}
        end
      else
        {:cont, :ok}
      end
    end)
  end

  defp validate_boolean_fields(fields) do
    Enum.reduce_while(@boolean_fields, :ok, fn field, :ok ->
      if Map.has_key?(fields, field) do
        case Map.get(fields, field) do
          value when is_boolean(value) -> {:cont, :ok}
          value -> {:halt, {:error, {:invalid_boolean, field, value}}}
        end
      else
        {:cont, :ok}
      end
    end)
  end

  defp validate_tips(%{currency: "XTR"} = fields) do
    case Enum.find([:max_tip_amount, :suggested_tip_amounts], &Map.has_key?(fields, &1)) do
      nil -> :ok
      field -> {:error, {:xtr_unsupported_field, field}}
    end
  end

  defp validate_tips(%{suggested_tip_amounts: amounts} = fields) do
    with :ok <- validate_suggested_tip_amounts(amounts),
         :ok <- validate_suggested_tip_max(amounts, Map.get(fields, :max_tip_amount)) do
      :ok
    end
  end

  defp validate_tips(_fields), do: :ok

  defp validate_suggested_tip_amounts(amounts) when is_list(amounts) do
    cond do
      length(amounts) > 4 ->
        {:error, {:suggested_tip_amounts, {:too_many, length(amounts)}}}

      not Enum.all?(amounts, &(is_integer(&1) and &1 > 0)) ->
        {:error, {:suggested_tip_amounts, :positive_integers_required}}

      amounts != Enum.sort(amounts) or length(amounts) != MapSet.size(MapSet.new(amounts)) ->
        {:error, {:suggested_tip_amounts, :not_strictly_increasing}}

      true ->
        :ok
    end
  end

  defp validate_suggested_tip_amounts(_amounts),
    do: {:error, {:suggested_tip_amounts, :integer_list_required}}

  defp validate_suggested_tip_max(_amounts, nil),
    do: {:error, {:suggested_tip_amounts, :max_tip_amount_required}}

  defp validate_suggested_tip_max([], _max_tip_amount), do: :ok

  defp validate_suggested_tip_max(amounts, max_tip_amount) do
    max_amount = List.last(amounts)

    if max_amount <= max_tip_amount do
      :ok
    else
      {:error, {:suggested_tip_amounts, {:exceeds_max_tip_amount, max_amount, max_tip_amount}}}
    end
  end

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message({:required, field}),
    do: "Nadia.InputInvoiceMessageContent #{field} is required"

  defp error_message({:invalid_string, field, _range, _unit}),
    do:
      "Nadia.InputInvoiceMessageContent #{field} must be a valid UTF-8 binary with official length bounds"

  defp error_message({:invalid_currency, currency}),
    do:
      "Nadia.InputInvoiceMessageContent currency must be a three-letter uppercase code, got: #{inspect(currency)}"

  defp error_message({:invalid_prices, _prices}),
    do: "Nadia.InputInvoiceMessageContent prices must be a list"

  defp error_message({:prices_size, 0}),
    do: "Nadia.InputInvoiceMessageContent prices must contain at least one item"

  defp error_message({:xtr_prices_size, count}),
    do: "Nadia.InputInvoiceMessageContent XTR prices must contain exactly one item, got: #{count}"

  defp error_message({:xtr_provider_token, _token}),
    do: "Nadia.InputInvoiceMessageContent XTR provider_token must be an empty string"

  defp error_message({:xtr_unsupported_field, field}),
    do: "Nadia.InputInvoiceMessageContent #{field} is not supported for XTR payments"

  defp error_message({:price, index, reason}),
    do: "invalid Nadia.InputInvoiceMessageContent price at index #{index}: #{inspect(reason)}"

  defp error_message(reason),
    do: "invalid Nadia.InputInvoiceMessageContent value: #{inspect(reason)}"
end
