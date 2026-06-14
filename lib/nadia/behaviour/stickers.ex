defmodule Nadia.Behaviour.Stickers do
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

      @callback get_sticker_set(Client.t(), binary) ::
                  {:ok, Nadia.Model.StickerSet.t()} | {:error, Error.t()}
      @callback get_custom_emoji_stickers([binary] | binary) ::
                  {:ok, [Sticker.t()]} | {:error, Error.t()}
      @callback get_custom_emoji_stickers(Client.t(), [binary] | binary) ::
                  {:ok, [Sticker.t()]} | {:error, Error.t()}
      @callback upload_sticker_file(Client.t(), integer, binary) ::
                  {:ok, File.t()} | {:error, Error.t()}
      @callback create_new_sticker_set(Client.t(), integer, binary, binary, binary, binary, [
                  {atom, any}
                ]) ::
                  :ok | {:error, Error.t()}
      @callback add_sticker_to_set(Client.t(), integer, binary, binary, binary, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback replace_sticker_in_set(integer, binary, binary, list | map | struct | binary) ::
                  :ok | {:error, Error.t()}
      @callback replace_sticker_in_set(
                  Client.t(),
                  integer,
                  binary,
                  binary,
                  list | map | struct | binary
                ) ::
                  :ok | {:error, Error.t()}
      @callback set_sticker_emoji_list(binary, [binary] | binary) :: :ok | {:error, Error.t()}
      @callback set_sticker_emoji_list(Client.t(), binary, [binary] | binary) ::
                  :ok | {:error, Error.t()}
      @callback set_sticker_keywords(binary) :: :ok | {:error, Error.t()}
      @callback set_sticker_keywords(binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
      @callback set_sticker_keywords(Client.t(), binary) :: :ok | {:error, Error.t()}
      @callback set_sticker_keywords(Client.t(), binary, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback set_sticker_mask_position(binary) :: :ok | {:error, Error.t()}
      @callback set_sticker_mask_position(binary, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback set_sticker_mask_position(Client.t(), binary) :: :ok | {:error, Error.t()}
      @callback set_sticker_mask_position(Client.t(), binary, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback set_sticker_set_title(binary, binary) :: :ok | {:error, Error.t()}
      @callback set_sticker_set_title(Client.t(), binary, binary) :: :ok | {:error, Error.t()}
      @callback set_sticker_set_thumbnail(binary, integer) :: :ok | {:error, Error.t()}
      @callback set_sticker_set_thumbnail(binary, integer, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback set_sticker_set_thumbnail(Client.t(), binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback set_sticker_set_thumbnail(Client.t(), binary, integer, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback set_custom_emoji_sticker_set_thumbnail(binary) :: :ok | {:error, Error.t()}
      @callback set_custom_emoji_sticker_set_thumbnail(binary, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback set_custom_emoji_sticker_set_thumbnail(Client.t(), binary) ::
                  :ok | {:error, Error.t()}
      @callback set_custom_emoji_sticker_set_thumbnail(Client.t(), binary, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback set_sticker_position_in_set(Client.t(), binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback delete_sticker_from_set(Client.t(), binary) :: :ok | {:error, Error.t()}
      @callback delete_sticker_set(binary) :: :ok | {:error, Error.t()}
      @callback delete_sticker_set(Client.t(), binary) :: :ok | {:error, Error.t()}
    end
  end
end
