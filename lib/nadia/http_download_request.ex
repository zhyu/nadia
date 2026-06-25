defmodule Nadia.HTTPDownloadRequest do
  @moduledoc """
  Streaming request passed to adapters that implement Nadia's optional
  download callback.

  The URL contains the bot token. Conforming adapters must not log it, return
  it in errors, follow redirects, retry, buffer the response, or call `sink`
  after it returns an error. The sink enforces Nadia's destination byte limit.
  """

  @enforce_keys [:url, :sink, :max_bytes]
  defstruct method: :get,
            url: nil,
            sink: nil,
            max_bytes: nil,
            expected_bytes: nil,
            headers: [],
            options: []

  @type sink :: (iodata -> :ok | {:error, term})

  @type t :: %__MODULE__{
          method: :get,
          url: binary,
          sink: sink,
          max_bytes: non_neg_integer,
          expected_bytes: non_neg_integer | nil,
          headers: list,
          options: keyword
        }
end

defimpl Inspect, for: Nadia.HTTPDownloadRequest do
  import Inspect.Algebra

  def inspect(request, opts) do
    fields =
      request
      |> Map.from_struct()
      |> Map.put(:url, "[REDACTED]")
      |> Map.put(:sink, "[REDACTED]")

    concat(["#Nadia.HTTPDownloadRequest<", to_doc(fields, opts), ">"])
  end
end
