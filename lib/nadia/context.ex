defmodule Nadia.Context do
  @moduledoc """
  Convenience helpers for working with incoming Telegram updates.

  `Nadia.Context` does not replace the raw Bot API wrappers. It extracts the
  common message, chat, and user values from an update and provides small reply
  helpers that delegate to existing `Nadia` functions.
  """

  alias Nadia.Client

  alias Nadia.Model.{
    BusinessMessagesDeleted,
    CallbackQuery,
    Chat,
    ChatBoostRemoved,
    ChatBoostUpdated,
    ChatJoinRequest,
    Error,
    InlineQuery,
    Message,
    MessageReactionCountUpdated,
    MessageReactionUpdated,
    Update,
    User
  }

  defstruct client: nil,
            update: nil,
            message: nil,
            callback_query: nil,
            inline_query: nil,
            chat: nil,
            from: nil,
            chat_id: nil,
            message_id: nil

  @type t :: %__MODULE__{
          client: Client.t() | nil,
          update: Update.t(),
          message: Message.t() | nil,
          callback_query: CallbackQuery.t() | nil,
          inline_query: InlineQuery.t() | nil,
          chat: Chat.t() | nil,
          from: User.t() | nil,
          chat_id: integer | binary | nil,
          message_id: integer | nil
        }

  @doc """
  Builds a context from a parsed Telegram update.

  The second argument may be a `%Nadia.Client{}` or options containing
  `:client`. When no client is supplied, reply helpers use Nadia's existing
  application-config based wrappers.
  """
  @spec new(Update.t(), Client.t() | keyword | map | nil) :: t
  def new(update, client_or_opts \\ [])

  def new(%Update{} = update, client_or_opts) do
    message = effective_message(update)
    chat = effective_chat(update)

    %__MODULE__{
      client: context_client(client_or_opts),
      update: update,
      message: message,
      callback_query: update.callback_query,
      inline_query: update.inline_query,
      chat: chat,
      from: effective_user(update),
      chat_id: chat && chat.id,
      message_id: message && message.message_id
    }
  end

  @doc """
  Returns the message most directly associated with an update or context.

  Callback query messages are considered effective messages so callback-driven
  handlers can reply to the chat that produced the callback.
  """
  @spec effective_message(t | Update.t()) :: Message.t() | nil
  def effective_message(%__MODULE__{message: message}), do: message

  def effective_message(%Update{} = update) do
    update.message ||
      update.edited_message ||
      update.channel_post ||
      update.edited_channel_post ||
      update.business_message ||
      update.edited_business_message ||
      update.guest_message ||
      callback_message(update.callback_query)
  end

  @doc """
  Returns the chat most directly associated with an update or context.
  """
  @spec effective_chat(t | Update.t()) :: Chat.t() | nil
  def effective_chat(%__MODULE__{chat: chat}), do: chat

  def effective_chat(%Update{} = update) do
    with nil <- message_chat(effective_message(update)),
         nil <- business_messages_deleted_chat(update.deleted_business_messages),
         nil <- chat_join_request_chat(update.chat_join_request),
         nil <- message_reaction_chat(update.message_reaction),
         nil <- message_reaction_count_chat(update.message_reaction_count),
         nil <- chat_boost_chat(update.chat_boost) do
      removed_chat_boost_chat(update.removed_chat_boost)
    end
  end

  @doc """
  Returns the user most directly associated with an update or context.
  """
  @spec effective_user(t | Update.t()) :: User.t() | nil
  def effective_user(%__MODULE__{from: from}), do: from

  def effective_user(%Update{} = update) do
    with nil <- message_from(effective_message(update)),
         nil <- callback_query_from(update.callback_query),
         nil <- inline_query_from(update.inline_query),
         nil <- chosen_inline_result_from(update.chosen_inline_result),
         nil <- message_reaction_user(update.message_reaction),
         nil <- chat_join_request_from(update.chat_join_request) do
      poll_answer_user(update.poll_answer)
    end
  end

  @doc """
  Returns the effective chat id for an update or context.
  """
  @spec chat_id(t | Update.t()) :: integer | binary | nil
  def chat_id(%__MODULE__{chat_id: chat_id}), do: chat_id

  def chat_id(%Update{} = update) do
    case effective_chat(update) do
      %Chat{id: chat_id} -> chat_id
      _ -> nil
    end
  end

  @doc """
  Sends a text message to the context's effective chat.

  Returns the same result shape as `Nadia.send_message/3`.
  """
  @spec reply(t, binary, keyword) :: {:ok, Message.t()} | {:error, Error.t()}
  def reply(context, text, options \\ [])

  def reply(%__MODULE__{chat_id: nil}, _text, _options) do
    {:error, %Error{reason: "cannot reply without an effective chat"}}
  end

  def reply(%__MODULE__{client: %Client{} = client, chat_id: chat_id}, text, options) do
    Nadia.send_message(client, chat_id, text, options)
  end

  def reply(%__MODULE__{chat_id: chat_id}, text, options) do
    Nadia.send_message(chat_id, text, options)
  end

  @doc """
  Answers the context's callback query.

  Returns the same result shape as `Nadia.answer_callback_query/2`.
  """
  @spec answer_callback(t, keyword) :: :ok | {:error, Error.t()}
  def answer_callback(context, options \\ [])

  def answer_callback(%__MODULE__{callback_query: %CallbackQuery{id: id}} = context, options)
      when is_binary(id) do
    do_answer_callback(context, options)
  end

  def answer_callback(%__MODULE__{}, _options) do
    {:error, %Error{reason: "cannot answer callback without a callback query"}}
  end

  defp do_answer_callback(
         %__MODULE__{client: %Client{} = client, callback_query: callback},
         options
       ) do
    Nadia.answer_callback_query(client, callback.id, options)
  end

  defp do_answer_callback(%__MODULE__{callback_query: callback}, options) do
    Nadia.answer_callback_query(callback.id, options)
  end

  defp context_client(%Client{} = client), do: client
  defp context_client(options) when is_list(options), do: Keyword.get(options, :client)
  defp context_client(%{client: client}), do: client
  defp context_client(_options), do: nil

  defp callback_message(%CallbackQuery{message: %Message{} = message}), do: message
  defp callback_message(_callback_query), do: nil

  defp message_chat(%Message{chat: %Chat{} = chat}), do: chat
  defp message_chat(_message), do: nil

  defp message_from(%Message{from: %User{} = from}), do: from
  defp message_from(_message), do: nil

  defp callback_query_from(%CallbackQuery{from: %User{} = from}), do: from
  defp callback_query_from(_callback_query), do: nil

  defp inline_query_from(%InlineQuery{from: %User{} = from}), do: from
  defp inline_query_from(_inline_query), do: nil

  defp chosen_inline_result_from(%{from: %User{} = from}), do: from
  defp chosen_inline_result_from(_chosen_inline_result), do: nil

  defp business_messages_deleted_chat(%BusinessMessagesDeleted{chat: %Chat{} = chat}), do: chat
  defp business_messages_deleted_chat(_deleted_business_messages), do: nil

  defp chat_join_request_chat(%ChatJoinRequest{chat: %Chat{} = chat}), do: chat
  defp chat_join_request_chat(_chat_join_request), do: nil

  defp chat_join_request_from(%ChatJoinRequest{from: %User{} = from}), do: from
  defp chat_join_request_from(_chat_join_request), do: nil

  defp message_reaction_chat(%MessageReactionUpdated{chat: %Chat{} = chat}), do: chat
  defp message_reaction_chat(_message_reaction), do: nil

  defp message_reaction_user(%MessageReactionUpdated{user: %User{} = user}), do: user
  defp message_reaction_user(_message_reaction), do: nil

  defp message_reaction_count_chat(%MessageReactionCountUpdated{chat: %Chat{} = chat}), do: chat
  defp message_reaction_count_chat(_message_reaction_count), do: nil

  defp chat_boost_chat(%ChatBoostUpdated{chat: %Chat{} = chat}), do: chat
  defp chat_boost_chat(_chat_boost), do: nil

  defp removed_chat_boost_chat(%ChatBoostRemoved{chat: %Chat{} = chat}), do: chat
  defp removed_chat_boost_chat(_removed_chat_boost), do: nil

  defp poll_answer_user(%{user: %User{} = user}), do: user
  defp poll_answer_user(_poll_answer), do: nil
end
