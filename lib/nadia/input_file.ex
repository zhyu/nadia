defmodule Nadia.InputFile do
  @moduledoc """
  Explicitly identifies a Telegram file ID, URL, local path, in-memory upload,
  or known-size stream.

  Bare binary arguments accepted by existing Nadia wrappers remain supported.
  Use this module when path intent, an upload filename, or nested
  `attach://` composition must be unambiguous.

      Nadia.send_document(chat_id, Nadia.InputFile.file_id(file_id))
      Nadia.send_document(chat_id, Nadia.InputFile.url("https://example.com/file.pdf"))
      Nadia.send_document(chat_id, Nadia.InputFile.path("/srv/files/report.pdf"))

      Nadia.send_document(
        chat_id,
        Nadia.InputFile.bytes(pdf_iodata, "report.pdf", max_bytes: 5_000_000)
      )

  `stream/3` requires an exact byte size. The stream is consumed once and is
  never buffered or retried by Nadia. See the Media And Files guide for
  lifecycle and ambiguous-failure caveats.
  """

  defstruct source: nil,
            filename: nil,
            content_type: nil,
            size: nil,
            max_bytes: nil,
            attach_name: nil

  @type source ::
          {:file_id, term}
          | {:url, term}
          | {:path, term}
          | {:bytes, term}
          | {:stream, term}

  @type t :: %__MODULE__{
          source: source,
          filename: binary | nil,
          content_type: binary | nil,
          size: non_neg_integer | nil,
          max_bytes: non_neg_integer | nil,
          attach_name: binary | nil
        }

  @type option ::
          {:filename, binary}
          | {:content_type, binary}
          | {:max_bytes, non_neg_integer}
          | {:attach_name, binary}

  @type stream_option :: option | {:size, non_neg_integer}

  @doc "Returns an explicit Telegram file ID reference."
  @spec file_id(binary) :: t
  def file_id(file_id), do: %__MODULE__{source: {:file_id, file_id}}

  @doc "Returns an explicit HTTP or HTTPS URL reference."
  @spec url(binary) :: t
  def url(url), do: %__MODULE__{source: {:url, url}}

  @doc "Returns an explicit local-path upload. The path is checked before the request."
  @spec path(Path.t(), [option]) :: t
  def path(path, options \\ []) do
    %__MODULE__{source: {:path, path}}
    |> put_options(options)
  end

  @doc """
  Returns an in-memory iodata upload without flattening or copying its data.

  Set `:max_bytes` to enforce an application limit before the request starts.
  """
  @spec bytes(iodata, binary, [option]) :: t
  def bytes(bytes, filename, options \\ []) do
    %__MODULE__{source: {:bytes, bytes}, filename: filename}
    |> put_options(options)
  end

  @doc """
  Returns a single-use streaming upload.

  `:size` is required and must be the exact number of bytes yielded as iodata.
  Nadia does not retry, rewind, or take ownership of caller-managed resources.
  """
  @spec stream(Enumerable.t(), binary, [stream_option]) :: t
  def stream(stream, filename, options) when is_list(options) do
    %__MODULE__{source: {:stream, stream}, filename: filename, size: options[:size]}
    |> put_options(Keyword.delete(options, :size))
  end

  defp put_options(input_file, options) do
    Enum.reduce(options, input_file, fn
      {:filename, value}, input_file ->
        %{input_file | filename: value}

      {:content_type, value}, input_file ->
        %{input_file | content_type: value}

      {:max_bytes, value}, input_file ->
        %{input_file | max_bytes: value}

      {:attach_name, value}, input_file ->
        %{input_file | attach_name: value}

      {key, _value}, _input_file ->
        raise ArgumentError, "unsupported Nadia.InputFile option: #{inspect(key)}"
    end)
  end
end

defmodule Nadia.InputFile.JSONPayload do
  @moduledoc false
  @enforce_keys [:value]
  defstruct [:value]
end

defmodule Nadia.InputFile.StreamError do
  @moduledoc false
  defexception [:message]
end
