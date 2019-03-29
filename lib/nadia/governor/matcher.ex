defmodule Nadia.Governor.Matcher do
  @moduledoc """
      Each Bot has a Matcher GenServer which runs independent
      spawned_links for the functions and modules to run the commands
  """
  use GenServer
#  alias MafiaBot.Commands
  require Logger

  # Server

  def start_link(bot) do
    bot_name = Map.get(bot,:bot_name)
    name =  {:via, Registry, {Registry.BotMatcher, bot_name}}
    bot = Map.merge(bot, %{name: name})
    Logger.log :info, "Started matcher for bot #{bot_name}  "
    GenServer.start_link __MODULE__, bot, name: name
  end

  def init(bot) do
    {:ok, bot}
  end

  #Run command in task
  def handle_cast({message,token}, state) do
  #  Commands.match_message message
    Task.start fn ->
      apply(state.commands_module, :command, [message,token])
    end
    {:noreply, state}
  end

  # Client

  def match(matcher_name,message, token) do
    GenServer.cast(matcher_name, {message,token})
  end
end
