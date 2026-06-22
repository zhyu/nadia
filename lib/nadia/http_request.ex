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
