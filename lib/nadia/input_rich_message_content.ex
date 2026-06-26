defmodule Nadia.InputRichMessageContent do
  @moduledoc """
  Typed builder for Telegram `InputRichMessageContent`.

  The wrapped `Nadia.InputRichMessage` is validated for inline-query content,
  including the conservative rejection of a literal `<tg-thinking` prefix.
  """

  alias Nadia.InputRichMessage

  @enforce_keys [:rich_message]
  defstruct [:rich_message]

  @typedoc "Typed inline-query content containing a rich message."
  @opaque t :: %__MODULE__{rich_message: InputRichMessage.t()}

  @doc "Wraps a typed rich message for use as inline-query message content."
  @spec new(InputRichMessage.t()) :: t
  def new(rich_message) do
    content = %__MODULE__{rich_message: rich_message}

    case to_map(content) do
      {:ok, _map} -> content
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{rich_message: rich_message} = content) do
    with :ok <- validate_struct_fields(content),
         :ok <- validate_typed_rich_message(rich_message),
         :ok <- validate_inline_context(rich_message),
         {:ok, rich_message_map} <- InputRichMessage.to_map(rich_message) do
      {:ok, %{rich_message: rich_message_map}}
    end
  end

  def to_map(_content), do: {:error, :invalid_input_rich_message_content}

  defp validate_struct_fields(content) do
    case content
         |> Map.keys()
         |> Enum.sort()
         |> Enum.find(&(&1 not in [:__struct__, :rich_message])) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_typed_rich_message(%InputRichMessage{}), do: :ok
  defp validate_typed_rich_message(_rich_message), do: {:error, :typed_rich_message_required}

  defp validate_inline_context(rich_message) do
    case InputRichMessage.validate_context(rich_message, :inline_content) do
      :ok -> :ok
      {:error, reason} -> {:error, {:input_rich_message, reason}}
    end
  end

  defp error_message(:typed_rich_message_required),
    do: "Nadia.InputRichMessageContent requires a typed Nadia.InputRichMessage"

  defp error_message(reason),
    do: "invalid Nadia.InputRichMessageContent value: #{inspect(reason)}"
end
