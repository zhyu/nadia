defmodule Nadia.InputSticker do
  @moduledoc """
  Typed builders for stickers used by sticker-set methods.

  Each builder fixes Telegram's `format`, requires 1-20 emoji strings, omits
  `nil` fields, and preserves explicit `false` values. Static stickers may use
  a file ID, HTTP URL, or `Nadia.InputFile`; animated and video stickers cannot
  use HTTP URLs.

  `:mask_position` is meaningful only for mask sets. `:keywords` is meaningful
  only for regular and custom-emoji sets and accepts at most 20 strings whose
  combined length is at most 64 characters.
  """

  alias Nadia.InputFile

  @enforce_keys [:variant, :sticker, :emoji_list]
  defstruct [:variant, :sticker, :emoji_list, :mask_position, :keywords]

  @typedoc "A typed Telegram InputSticker value. Its representation is opaque."
  @opaque t :: %__MODULE__{
            variant: :static | :animated | :video,
            sticker: binary | InputFile.t(),
            emoji_list: [binary],
            mask_position: term,
            keywords: [binary] | nil
          }

  @type source :: binary | InputFile.t()
  @type options :: keyword | map

  @doc "Builds a static WEBP or PNG sticker."
  @spec static(source, [binary], options) :: t
  def static(sticker, emoji_list, options \\ []),
    do: build(:static, sticker, emoji_list, options)

  @doc "Builds an animated TGS sticker. HTTP URLs are rejected."
  @spec animated(source, [binary], options) :: t
  def animated(sticker, emoji_list, options \\ []),
    do: build(:animated, sticker, emoji_list, options)

  @doc "Builds a video WEBM sticker. HTTP URLs are rejected."
  @spec video(source, [binary], options) :: t
  def video(sticker, emoji_list, options \\ []),
    do: build(:video, sticker, emoji_list, options)

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{} = input) do
    with :ok <- validate_variant(input.variant),
         :ok <- validate_source(input.sticker),
         :ok <- validate_url(input.variant, input.sticker),
         :ok <- validate_emoji_list(input.emoji_list),
         :ok <- validate_keywords(input.keywords) do
      {:ok,
       %{
         sticker: input.sticker,
         format: Atom.to_string(input.variant),
         emoji_list: input.emoji_list,
         mask_position: input.mask_position,
         keywords: input.keywords
       }
       |> reject_nil_values()}
    end
  end

  @doc false
  @spec validate_sticker_set(term) :: :ok | {:error, term}
  def validate_sticker_set([]), do: {:error, {:sticker_set_size, 0}}

  def validate_sticker_set(stickers) when is_list(stickers) do
    if Enum.all?(stickers, &match?(%__MODULE__{}, &1)) do
      if length(stickers) in 1..50 do
        Enum.reduce_while(stickers, :ok, fn sticker, :ok ->
          case to_map(sticker) do
            {:ok, _map} -> {:cont, :ok}
            {:error, reason} -> {:halt, {:error, reason}}
          end
        end)
      else
        {:error, {:sticker_set_size, length(stickers)}}
      end
    else
      :ok
    end
  end

  def validate_sticker_set(_stickers), do: :ok

  defp build(variant, sticker, emoji_list, options) do
    input =
      %__MODULE__{
        variant: variant,
        sticker: sticker,
        emoji_list: emoji_list
      }
      |> put_options(options)

    case to_map(input) do
      {:ok, _map} -> input
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  defp put_options(input, options) when is_map(options),
    do: put_options(input, Map.to_list(options))

  defp put_options(input, options) when is_list(options) do
    if Keyword.keyword?(options) do
      Enum.reduce(options, input, fn
        {:mask_position, value}, input ->
          %{input | mask_position: value}

        {:keywords, value}, input ->
          %{input | keywords: value}

        {key, _value}, _input ->
          raise ArgumentError, "unsupported Nadia.InputSticker option: #{inspect(key)}"
      end)
    else
      raise ArgumentError, "Nadia.InputSticker options must be a keyword list or map"
    end
  end

  defp put_options(_input, _options),
    do: raise(ArgumentError, "Nadia.InputSticker options must be a keyword list or map")

  defp validate_variant(variant) when variant in [:static, :animated, :video], do: :ok
  defp validate_variant(variant), do: {:error, {:invalid_discriminator, variant}}

  defp validate_source(%InputFile{}), do: :ok
  defp validate_source(value) when is_binary(value) and byte_size(value) > 0, do: :ok
  defp validate_source(_value), do: {:error, :sticker_required}

  defp validate_url(:static, _sticker), do: :ok

  defp validate_url(variant, %InputFile{source: {:url, _url}}),
    do: {:error, {:url_not_supported, variant}}

  defp validate_url(variant, sticker) when is_binary(sticker) do
    if http_url?(sticker), do: {:error, {:url_not_supported, variant}}, else: :ok
  end

  defp validate_url(_variant, _sticker), do: :ok

  defp validate_emoji_list(values) when is_list(values) and length(values) in 1..20 do
    if Enum.all?(
         values,
         &(is_binary(&1) and byte_size(&1) > 0 and String.valid?(&1))
       ) do
      :ok
    else
      {:error, :invalid_emoji_list}
    end
  end

  defp validate_emoji_list(_values), do: {:error, :invalid_emoji_list}

  defp validate_keywords(nil), do: :ok

  defp validate_keywords(values) when is_list(values) and length(values) <= 20 do
    if Enum.all?(
         values,
         &(is_binary(&1) and byte_size(&1) > 0 and String.valid?(&1))
       ) and
         Enum.reduce(values, 0, &(String.length(&1) + &2)) <= 64 do
      :ok
    else
      {:error, :invalid_keywords}
    end
  end

  defp validate_keywords(_values), do: {:error, :invalid_keywords}

  defp http_url?(value) do
    case URI.parse(value) do
      %URI{scheme: scheme, host: host}
      when scheme in ["http", "https"] and is_binary(host) and byte_size(host) > 0 ->
        true

      _other ->
        false
    end
  end

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message(:sticker_required),
    do: "Nadia.InputSticker sticker must be a non-empty binary or InputFile"

  defp error_message(:invalid_emoji_list),
    do: "Nadia.InputSticker emoji_list must contain 1 to 20 non-empty strings"

  defp error_message(:invalid_keywords),
    do: "Nadia.InputSticker keywords must contain at most 20 strings and 64 characters"

  defp error_message({:url_not_supported, variant}),
    do: "Nadia.InputSticker #{variant} stickers do not support URLs"

  defp error_message(reason), do: "invalid Nadia.InputSticker value: #{inspect(reason)}"
end
