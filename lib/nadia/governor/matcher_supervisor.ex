defmodule Nadia.Supervisor.Matcher do
  @moduledoc  """
    Bot Matcher Supervisor
  """
  use Supervisor

  def start_link(bots) do
    Supervisor.start_link(__MODULE__,bots, name: __MODULE__)
  end

  def init(bots) do
    children  =    [
      
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
