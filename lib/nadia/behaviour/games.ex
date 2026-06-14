defmodule Nadia.Behaviour.Games do
  @moduledoc false

  defmacro __using__(_opts) do
    quote location: :keep do
      alias Nadia.Client

      alias Nadia.Model.{
        BotAccessSettings,
        BotCommand,
        BotDescription,
        BotName,
        BotShortDescription,
        BusinessConnection,
        Chat,
        ChatAdministratorRights,
        ChatInviteLink,
        ChatMember,
        Error,
        File,
        ForumTopic,
        GameHighScore,
        Gifts,
        MenuButton,
        Message,
        MessageId,
        OwnedGifts,
        Poll,
        PreparedInlineMessage,
        PreparedKeyboardButton,
        SentGuestMessage,
        SentWebAppMessage,
        StarAmount,
        StarTransactions,
        Story,
        Sticker,
        Update,
        User,
        UserChatBoosts,
        UserProfileAudios,
        UserProfilePhotos,
        WebhookInfo
      }

      @callback set_game_score(integer, integer) :: {:ok, Message.t()} | :ok | {:error, Error.t()}
      @callback set_game_score(integer, integer, [{atom, any}] | map) ::
                  {:ok, Message.t()} | :ok | {:error, Error.t()}
      @callback set_game_score(Client.t(), integer, integer) ::
                  {:ok, Message.t()} | :ok | {:error, Error.t()}
      @callback set_game_score(Client.t(), integer, integer, [{atom, any}] | map) ::
                  {:ok, Message.t()} | :ok | {:error, Error.t()}
      @callback get_game_high_scores(integer) :: {:ok, [GameHighScore.t()]} | {:error, Error.t()}
      @callback get_game_high_scores(integer, [{atom, any}] | map) ::
                  {:ok, [GameHighScore.t()]} | {:error, Error.t()}
      @callback get_game_high_scores(Client.t(), integer) ::
                  {:ok, [GameHighScore.t()]} | {:error, Error.t()}
      @callback get_game_high_scores(Client.t(), integer, [{atom, any}] | map) ::
                  {:ok, [GameHighScore.t()]} | {:error, Error.t()}
    end
  end
end
