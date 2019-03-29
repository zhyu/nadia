defmodule Nadia.Supervisor.BotSupervisor do
  @moduledoc  """
    Bot Supervisor
  """
  use Supervisor

  def start_link(bots) do
    Supervisor.start_link(__MODULE__,bots, name: __MODULE__)
  end

  def init(bots) do
    children = [
        {Registry, [keys: :unique, name: Registry.BotPoller]},
        {Registry, [keys: :unique, name: Registry.BotMatcher]},
        Supervisor.child_spec({Nadia.Supervisor.Matcher, []}, type: :supervisor),
        Supervisor.child_spec({Nadia.Supervisor.Poller, bots}, type: :supervisor),

    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
