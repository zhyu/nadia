defmodule Nadia.HTTPDownloadResponse do
  @moduledoc """
  Bounded response metadata returned by streaming HTTP adapters.

  Response bodies, request URLs, and redirect locations are deliberately not
  represented.
  """

  @enforce_keys [:status_code, :bytes_written]
  defstruct status_code: nil, bytes_written: 0, headers: []

  @type t :: %__MODULE__{
          status_code: non_neg_integer,
          bytes_written: non_neg_integer,
          headers: list
        }
end
