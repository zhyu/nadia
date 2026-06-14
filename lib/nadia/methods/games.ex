defmodule Nadia.Methods.Games do
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
        ChatAdministratorRights,
        ChatInviteLink,
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

      @doc """
      Use this method to set a user's score in a game message.
      On success, the edited Message is returned, or `:ok` is returned when editing
      an inline message.

      Args:
      * `user_id` - User identifier
      * `score` - New score
      * `options` - orddict or map of options
      """
      @spec set_game_score(integer, integer) :: {:ok, Message.t()} | :ok | {:error, Error.t()}
      @spec set_game_score(integer, integer, [{atom, any}] | map) ::
              {:ok, Message.t()} | :ok | {:error, Error.t()}
      @spec set_game_score(Client.t(), integer, integer) ::
              {:ok, Message.t()} | :ok | {:error, Error.t()}
      @spec set_game_score(Client.t(), integer, integer, [{atom, any}] | map) ::
              {:ok, Message.t()} | :ok | {:error, Error.t()}
      def set_game_score(user_id, score), do: set_game_score(user_id, score, [])

      def set_game_score(%Client{} = client, user_id, score) do
        set_game_score(client, user_id, score, [])
      end

      def set_game_score(user_id, score, options) do
        api_request("setGameScore", request_options([user_id: user_id, score: score], options))
      end

      def set_game_score(%Client{} = client, user_id, score, options) do
        api_request(
          client,
          "setGameScore",
          request_options([user_id: user_id, score: score], options)
        )
      end

      @doc """
      Use this method to get data for game high score tables.
      Returns a list of GameHighScore objects.

      Args:
      * `user_id` - Target user identifier
      * `options` - orddict or map of options
      """
      @spec get_game_high_scores(integer) :: {:ok, [GameHighScore.t()]} | {:error, Error.t()}
      @spec get_game_high_scores(integer, [{atom, any}] | map) ::
              {:ok, [GameHighScore.t()]} | {:error, Error.t()}
      @spec get_game_high_scores(Client.t(), integer) ::
              {:ok, [GameHighScore.t()]} | {:error, Error.t()}
      @spec get_game_high_scores(Client.t(), integer, [{atom, any}] | map) ::
              {:ok, [GameHighScore.t()]} | {:error, Error.t()}
      def get_game_high_scores(user_id), do: get_game_high_scores(user_id, [])

      def get_game_high_scores(%Client{} = client, user_id) do
        get_game_high_scores(client, user_id, [])
      end

      def get_game_high_scores(user_id, options) do
        api_request("getGameHighScores", request_options([user_id: user_id], options))
      end

      def get_game_high_scores(%Client{} = client, user_id, options) do
        api_request(client, "getGameHighScores", request_options([user_id: user_id], options))
      end
    end
  end
end
