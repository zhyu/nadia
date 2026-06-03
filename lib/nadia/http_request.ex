defmodule Nadia.HTTPRequest do
  @moduledoc false

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
