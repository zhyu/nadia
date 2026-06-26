defmodule Nadia.LabeledPrice do
  @moduledoc """
  Typed builder for Telegram `LabeledPrice` objects.

  Amounts must be integers in the smallest units of the currency. Telegram
  remains responsible for currency-specific limits and payment-provider rules.
  """

  @enforce_keys [:fields]
  defstruct [:fields]

  @typedoc "A typed Telegram LabeledPrice value. Its representation is opaque."
  @opaque t :: %__MODULE__{fields: map}

  @type raw :: keyword | map | struct

  @allowed_fields [:label, :amount]

  @doc "Builds a labeled price portion."
  @spec new(binary, integer) :: t
  def new(label, amount) do
    price = %__MODULE__{fields: %{label: label, amount: amount}}

    case to_map(price) do
      {:ok, _map} -> price
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{fields: fields}) do
    with :ok <- validate_fields_map(fields),
         :ok <- validate_allowed_fields(fields),
         :ok <- validate_label(Map.get(fields, :label)),
         :ok <- validate_amount(Map.get(fields, :amount)) do
      {:ok, Map.take(fields, @allowed_fields)}
    end
  end

  def to_map(_price), do: {:error, :invalid_labeled_price}

  @doc false
  @spec normalize(t | raw) :: {:ok, map} | {:error, term}
  def normalize(%__MODULE__{} = price), do: to_map(price)

  def normalize(price) when is_list(price) do
    if Keyword.keyword?(price) do
      price
      |> Map.new()
      |> normalize_map()
    else
      {:error, :invalid_labeled_price}
    end
  end

  def normalize(%_{} = price) do
    price
    |> Map.from_struct()
    |> normalize_map()
  end

  def normalize(price) when is_map(price), do: normalize_map(price)
  def normalize(_price), do: {:error, :invalid_labeled_price}

  defp normalize_map(price) do
    fields = %{
      label: known_value(price, :label),
      amount: known_value(price, :amount)
    }

    with :ok <- validate_label(fields.label),
         :ok <- validate_amount(fields.amount) do
      {:ok, fields}
    end
  end

  defp known_value(map, field) do
    Map.get(map, field, Map.get(map, Atom.to_string(field)))
  end

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

  defp validate_label(nil), do: {:error, {:required, :label}}

  defp validate_label(label) when is_binary(label) do
    if String.valid?(label), do: :ok, else: {:error, :invalid_label}
  end

  defp validate_label(_label), do: {:error, :invalid_label}

  defp validate_amount(nil), do: {:error, {:required, :amount}}
  defp validate_amount(amount) when is_integer(amount), do: :ok
  defp validate_amount(amount), do: {:error, {:invalid_amount, amount}}

  defp error_message({:required, field}),
    do: "Nadia.LabeledPrice #{field} is required"

  defp error_message(:invalid_label),
    do: "Nadia.LabeledPrice label must be a valid UTF-8 binary"

  defp error_message({:invalid_amount, amount}),
    do: "Nadia.LabeledPrice amount must be an integer, got: #{inspect(amount)}"

  defp error_message(reason), do: "invalid Nadia.LabeledPrice value: #{inspect(reason)}"
end
