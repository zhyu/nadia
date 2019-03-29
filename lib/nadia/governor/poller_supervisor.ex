defmodule Nadia.Supervisor.Poller do
  @moduledoc  """
    Bot Poller Supervisor
  """
  use Supervisor

  def start_link(bots) do
    Supervisor.start_link(__MODULE__,bots, name: __MODULE__)
  end

  def init(bots) do
    children  =   Enum.map(bots,fn (bot) ->
      #:crypto.strong_rand_bytes(5) |> Base.encode32
      Supervisor.child_spec({Nadia.Governor.Poller, bot}, id: bot.bot_name )
    end)

    Supervisor.init(children, strategy: :one_for_one)
  end

end
