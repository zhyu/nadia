defmodule Nadia.ReactionType do
  @moduledoc """
  Typed builders for Telegram `ReactionType` objects.

  Builders fix the Telegram `type` discriminator. Emoji and custom-emoji
  identifiers must be non-empty valid UTF-8 strings.
  """

  @enforce_keys [:variant, :fields]
  defstruct [:variant, :fields]

  @typedoc "A typed Telegram ReactionType value. Its representation is opaque."
  @opaque t :: %__MODULE__{variant: variant, fields: map}

  @type variant :: :emoji | :custom_emoji | :paid

  @variants [:emoji, :custom_emoji, :paid]

  @doc "Builds a standard emoji reaction."
  @spec emoji(binary) :: t
  def emoji(emoji), do: build(:emoji, %{emoji: emoji})

  @doc "Builds a custom emoji reaction."
  @spec custom_emoji(binary) :: t
  def custom_emoji(custom_emoji_id) do
    build(:custom_emoji, %{custom_emoji_id: custom_emoji_id})
  end

  @doc "Builds a paid reaction."
  @spec paid() :: t
  def paid, do: build(:paid, %{})

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{variant: variant, fields: fields}) do
    with :ok <- validate_variant(variant),
         :ok <- validate_fields_map(fields),
         :ok <- validate_allowed_fields(variant, fields),
         :ok <- validate_fields(variant, fields) do
      {:ok, Map.put(fields, :type, Atom.to_string(variant))}
    end
  end

  defp build(variant, fields) do
    reaction = %__MODULE__{variant: variant, fields: fields}

    case to_map(reaction) do
      {:ok, _map} -> reaction
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  defp validate_variant(variant) when variant in @variants, do: :ok
  defp validate_variant(variant), do: {:error, {:invalid_discriminator, variant}}

  defp validate_fields_map(fields) when is_map(fields), do: :ok
  defp validate_fields_map(fields), do: {:error, {:invalid_fields, fields}}

  defp validate_allowed_fields(variant, fields) do
    allowed =
      case variant do
        :emoji -> [:emoji]
        :custom_emoji -> [:custom_emoji_id]
        :paid -> []
      end

    case fields |> Map.keys() |> Enum.sort() |> Enum.find(&(&1 not in allowed)) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_fields(:emoji, fields), do: validate_string(fields[:emoji], :emoji)

  defp validate_fields(:custom_emoji, fields),
    do: validate_string(fields[:custom_emoji_id], :custom_emoji_id)

  defp validate_fields(:paid, _fields), do: :ok

  defp validate_string(value, _field)
       when is_binary(value) and byte_size(value) > 0,
       do: if(String.valid?(value), do: :ok, else: {:error, :invalid_utf8})

  defp validate_string(_value, field), do: {:error, {:required, field}}

  defp error_message({:required, field}),
    do: "Nadia.ReactionType #{field} must be a non-empty valid UTF-8 string"

  defp error_message(:invalid_utf8),
    do: "Nadia.ReactionType values must be valid UTF-8 strings"

  defp error_message(reason), do: "invalid Nadia.ReactionType value: #{inspect(reason)}"
end
