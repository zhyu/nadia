defmodule Nadia.HTTPRequest do
  @moduledoc """
  Request struct passed to Nadia HTTP adapters.

  Multipart bodies use `{:multipart, parts}`. File parts have the form
  `{:file, source, disposition, headers}`, where `source` is a local path,
  `{:bytes, iodata, size}`, or `{:stream, enumerable, size}`. Custom adapters
  must consume stream sources once and must not silently retry them.
  """

  @enforce_keys [:method, :url]
  defstruct method: nil, url: nil, body: nil, headers: [], options: []

  @type t :: %__MODULE__{
          method: atom,
          url: binary,
          body: term,
          headers: list,
          options: keyword
        }
end

defimpl Inspect, for: Nadia.HTTPRequest do
  import Inspect.Algebra

  def inspect(request, opts) do
    fields =
      request
      |> Map.from_struct()
      |> Map.update!(:url, &redact_bot_token/1)

    concat(["#Nadia.HTTPRequest<", to_doc(fields, opts), ">"])
  end

  defp redact_bot_token(url) when is_binary(url),
    do: Regex.replace(~r|(/bot)[^/]+|, url, "\\1[REDACTED]")

  defp redact_bot_token(_url), do: "[REDACTED]"
end
