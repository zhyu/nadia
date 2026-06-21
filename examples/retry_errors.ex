defmodule Nadia.Examples.RetryErrors do
  @moduledoc """
  Bounded handling for Telegram flood-control and chat-migration errors.
  """

  alias Nadia.Model.{Error, ResponseParameters}

  @type option ::
          {:max_attempts, pos_integer}
          | {:max_delay_seconds, non_neg_integer}
          | {:sleep, (non_neg_integer -> any)}

  @doc """
  Calls a zero-arity function and retries only Telegram responses carrying a
  usable `retry_after` value.

  A delay larger than `:max_delay_seconds` is returned to the caller unchanged
  instead of sleeping for an unexpectedly long time.
  """
  @spec retry((-> term), [option]) :: term
  def retry(fun, options \\ []) when is_function(fun, 0) do
    max_attempts = Keyword.get(options, :max_attempts, 3)
    max_delay = Keyword.get(options, :max_delay_seconds, 30)
    sleep = Keyword.get(options, :sleep, &Process.sleep/1)

    if is_integer(max_attempts) and max_attempts > 0 and is_integer(max_delay) and
         max_delay >= 0 and is_function(sleep, 1) do
      retry(fun, max_attempts, max_delay, sleep)
    else
      {:error, :invalid_retry_options}
    end
  end

  @doc """
  Returns Telegram's replacement chat ID when an error reports a migration.

  Persist the replacement in application-owned storage before deliberately
  issuing a new request for the migrated chat.
  """
  @spec migration_target(Error.t()) :: {:ok, integer} | :error
  def migration_target(%Error{
        parameters: %ResponseParameters{migrate_to_chat_id: chat_id}
      })
      when is_integer(chat_id),
      do: {:ok, chat_id}

  def migration_target(%Error{}), do: :error

  defp retry(fun, attempts_left, max_delay, sleep) do
    case fun.() do
      {:error, %Error{parameters: %ResponseParameters{retry_after: delay_seconds}}}
      when is_integer(delay_seconds) and delay_seconds >= 0 and attempts_left > 1 and
             delay_seconds <= max_delay ->
        sleep.(delay_seconds * 1_000)
        retry(fun, attempts_left - 1, max_delay, sleep)

      response ->
        response
    end
  end
end
