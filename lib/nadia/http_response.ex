defmodule Nadia.HTTPResponse do
  @moduledoc false

  @enforce_keys [:body]
  defstruct status_code: nil, body: "", headers: []

  @type t :: %__MODULE__{
          status_code: integer | nil,
          body: binary,
          headers: list
        }
end
