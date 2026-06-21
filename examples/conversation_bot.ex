defmodule Nadia.Examples.ConversationBot do
  @moduledoc false

  @behaviour Nadia.Handler

  alias Nadia.Context
  alias Nadia.Dispatcher
  alias Nadia.SessionStore

  @store {Nadia.SessionStore.ETS, Nadia.Examples.ConversationBot.Sessions}

  @impl Nadia.Handler
  def handle_update(_update, context) do
    cond do
      match?({:ok, _match}, Dispatcher.match_command(context, "start")) ->
        start_conversation(context)

      match?({:ok, _match}, Dispatcher.match_command(context, "cancel")) ->
        cancel_conversation(context)

      true ->
        continue_conversation(context)
    end
  end

  def store, do: @store

  defp start_conversation(context) do
    with_session_key(context, fn key ->
      with {:ok, _message} <- Context.reply(context, "What is your name?"),
           :ok <- SessionStore.put(@store, key, %{step: :name}) do
        :ok
      end
    end)
  end

  defp cancel_conversation(context) do
    with_session_key(context, fn key ->
      with {:ok, _message} <- Context.reply(context, "Cancelled."),
           :ok <- SessionStore.delete(@store, key) do
        :ok
      end
    end)
  end

  defp continue_conversation(context) do
    with_session_key(context, fn key ->
      with {:ok, session} <- SessionStore.get(@store, key) do
        advance(context, key, session)
      end
    end)
  end

  defp advance(%Context{message: %{text: name}} = context, key, %{step: :name})
       when is_binary(name) do
    with {:ok, _message} <- Context.reply(context, "What is your email address?"),
         :ok <- SessionStore.put(@store, key, %{step: :email, name: name}) do
      :ok
    end
  end

  defp advance(%Context{message: %{text: email}} = context, key, %{
         step: :email,
         name: name
       })
       when is_binary(email) do
    with {:ok, _message} <- Context.reply(context, "Thanks #{name}. Received #{email}."),
         :ok <- SessionStore.delete(@store, key) do
      :ok
    end
  end

  defp advance(_context, _key, _session), do: :ignore

  defp with_session_key(context, fun) do
    case SessionStore.chat_user_key(context) do
      {:ok, key} -> fun.(key)
      {:error, :missing_chat_id} -> :ignore
      {:error, :missing_user_id} -> :ignore
    end
  end
end
