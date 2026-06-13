defmodule Nadia.Handler do
  @moduledoc """
  Behaviour for modules that handle incoming Telegram updates.

  Handlers receive the parsed `%Nadia.Model.Update{}` and a `Nadia.Context`
  with the effective message, chat, user, and client already extracted.
  """

  alias Nadia.Context
  alias Nadia.Model.Update

  @type result :: :ok | :ignore | {:ok, term} | {:error, term}

  @callback handle_update(Update.t(), Context.t()) :: result
end
