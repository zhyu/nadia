defmodule Nadia.HTTPResponse do
  @moduledoc """
  Response struct returned by Nadia HTTP adapters.
  """

  @enforce_keys [:body]
  defstruct status_code: nil, body: "", headers: []

  @type t :: %__MODULE__{
          status_code: integer | nil,
          body: binary,
          headers: list
        }
end
