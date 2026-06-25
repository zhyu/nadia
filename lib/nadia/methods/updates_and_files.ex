defmodule Nadia.Methods.UpdatesAndFiles do
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

      @doc group: "Updates And Files"
      @doc """
      Use this method to receive incoming updates using long polling.
      An Array of Update objects is returned.

      Args:
      * `options` - keyword list of options

      Options:
      * `:offset` - Identifier of the first update to be returned. Must be greater by one
      than the highest among the identifiers of previously received updates. By default,
      updates starting with the earliest unconfirmed update are returned. An update is
      considered confirmed as soon as `get_updates` is called with an `offset` higher than
      its `update_id`.
      * `:limit` - Limits the number of updates to be retrieved. Values between 1—100 are
      accepted. Defaults to 100
      * `:timeout` - Timeout in seconds for long polling. Defaults to 0, i.e. usual short
      polling
      * `:allowed_updates` - JSON-serializable list of update types to receive
      """
      @spec get_updates([{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
      @spec get_updates(Client.t(), [{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
      def get_updates(), do: get_updates([])
      @doc group: "Updates And Files"
      def get_updates(%Client{} = client), do: get_updates(client, [])

      def get_updates(options) do
        api_request("getUpdates", encode_json_array_option(options, :allowed_updates))
      end

      @doc group: "Updates And Files"
      def get_updates(%Client{} = client, options) do
        api_request(client, "getUpdates", encode_json_array_option(options, :allowed_updates))
      end

      @doc group: "Updates And Files"
      @doc """
      Use this method to specify a url and receive incoming updates via an outgoing
      webhook. Whenever there is an update for the bot, we will send an HTTPS POST
      request to the specified url, containing a JSON-serialized Update. In case of
      an unsuccessful request, we will give up after a reasonable amount of attempts.

      Args:
      * `options` - keyword list of options

      Options:
      * `:url` - HTTPS url to send updates to.
      * `:secret_token` - Secret token Telegram should send in the
      `X-Telegram-Bot-Api-Secret-Token` header.
      * `:allowed_updates` - JSON-serializable list of update types to receive.
      """
      @spec set_webhook([{atom, any}]) :: :ok | {:error, Error.t()}
      @spec set_webhook(Client.t(), [{atom, any}]) :: :ok | {:error, Error.t()}
      def set_webhook(), do: set_webhook([])
      @doc group: "Updates And Files"
      def set_webhook(%Client{} = client), do: set_webhook(client, [])

      def set_webhook(options) do
        api_request("setWebhook", encode_json_array_option(options, :allowed_updates))
      end

      @doc group: "Updates And Files"
      def set_webhook(%Client{} = client, options) do
        api_request(client, "setWebhook", encode_json_array_option(options, :allowed_updates))
      end

      @doc group: "Updates And Files"
      @doc """
      Use this method to remove webhook integration if you decide to switch back to `Nadia.get_updates/1`.
      Returns `:ok` on success.

      Args:
      * `options` - keyword list of options

      Options:
      * `:drop_pending_updates` - Pass True to drop all pending updates
      """
      @spec delete_webhook() :: :ok | {:error, Error.t()}
      @spec delete_webhook([{atom, any}]) :: :ok | {:error, Error.t()}
      @spec delete_webhook(Client.t()) :: :ok | {:error, Error.t()}
      @spec delete_webhook(Client.t(), [{atom, any}]) :: :ok | {:error, Error.t()}
      def delete_webhook(), do: delete_webhook([])
      @doc group: "Updates And Files"
      def delete_webhook(%Client{} = client), do: delete_webhook(client, [])
      def delete_webhook(options), do: api_request("deleteWebhook", options)

      @doc group: "Updates And Files"
      def delete_webhook(%Client{} = client, options),
        do: api_request(client, "deleteWebhook", options)

      @doc group: "Updates And Files"
      @doc """
      Use this method to get current webhook status. Requires no parameters.
      On success, returns a `Nadia.Model.WebhookInfo.t()` object with webhook details.
      If the bot is using getUpdates, will return an object with the url field empty.
      """
      @spec get_webhook_info() :: {:ok, WebhookInfo.t()} | {:error, Error.t()}
      @spec get_webhook_info(Client.t()) :: {:ok, WebhookInfo.t()} | {:error, Error.t()}
      def get_webhook_info(), do: api_request("getWebhookInfo")
      @doc group: "Updates And Files"
      def get_webhook_info(%Client{} = client), do: api_request(client, "getWebhookInfo")

      @doc group: "Updates And Files"
      @doc """
      Use this method to get basic info about a file and prepare it for downloading.
      For the moment, bots can download files of up to 20MB in size.
      On success, a File object is returned.
      The file can then be downloaded via the link
      `https://api.telegram.org/file/bot<token>/<file_path>`, where <file_path> is taken
      from the response. It is guaranteed that the link will be valid for at least 1 hour.
      When the link expires, a new one can be requested by calling `get_file` again.

      Args:
      * `file_id` - File identifier to get info about
      """
      @spec get_file(binary) :: {:ok, File.t()} | {:error, Error.t()}
      @spec get_file(Client.t(), binary) :: {:ok, File.t()} | {:error, Error.t()}
      def get_file(file_id), do: api_request("getFile", file_id: file_id)

      @doc group: "Updates And Files"
      def get_file(%Client{} = client, file_id),
        do: api_request(client, "getFile", file_id: file_id)

      @doc group: "Updates And Files"
      @doc ~S"""
      Use this method to get link for file for subsequent use.
      This method is an extension of the `get_file` method.

      The URL contains the bot token and should not be logged or exposed as a
      public permanent URL. If Telegram omits the optional `file_path`, this
      function returns an error with reason `:file_path_unavailable`.
      Absolute local-server paths are never concatenated into a URL; use
      `download_file` with `file_mode: :local` instead.

          iex> Nadia.get_file_link(%Nadia.Model.File{file_id: "BQADBQADBgADmEjsA1aqdSxtzvvVAg",
          ...> file_path: "document/file_10", file_size: 17680})
          {:ok,
          "https://api.telegram.org/file/bot#{Nadia.Config.token()}/document/file_10"}

      """
      @spec get_file_link(File.t()) :: {:ok, binary} | {:error, Error.t()}
      @spec get_file_link(Client.t(), File.t()) :: {:ok, binary} | {:error, Error.t()}
      def get_file_link(%File{file_path: file_path}) when is_binary(file_path),
        do: file_link(Client.default(), file_path)

      def get_file_link(%File{}), do: {:error, %Error{reason: :file_path_unavailable}}

      @doc group: "Updates And Files"
      def get_file_link(%Client{} = client, %File{file_path: file_path})
          when is_binary(file_path),
          do: file_link(client, file_path)

      def get_file_link(%Client{}, %File{}),
        do: {:error, %Error{reason: :file_path_unavailable}}

      @doc group: "Updates And Files"
      @doc """
      Downloads a Telegram file to an application-chosen path without buffering
      the complete response.

      `max_bytes` is mandatory. Nadia checks Telegram's optional `file_size`
      before transfer and enforces the same cap against every emitted chunk.
      The destination is not overwritten by default. A hidden, exclusive temp
      file is created in the destination directory, synced, and atomically
      published only after status and size validation.

      In the default `file_mode: :remote`, redirects and retries are disabled
      and token-bearing URLs never appear in results or normalized errors. Set
      `file_mode: :local` only for a trusted local Bot API server whose absolute
      `file_path` is accessible in Nadia's filesystem namespace.

      Options:
      * `:overwrite` - atomically replace the destination; defaults to `false`
      * `:receive_timeout` - receive timeout in milliseconds

      Existing custom HTTP adapters remain compatible. Downloads require the
      optional HTTP adapter download callback and fail with
      `{:download, :unsupported_http_adapter}` when it is absent.
      """
      @spec download_file(binary | File.t(), Path.t(), non_neg_integer) ::
              {:ok, Path.t()} | {:error, Error.t()}
      @spec download_file(binary | File.t(), Path.t(), non_neg_integer, keyword) ::
              {:ok, Path.t()} | {:error, Error.t()}
      @spec download_file(Client.t(), binary | File.t(), Path.t(), non_neg_integer) ::
              {:ok, Path.t()} | {:error, Error.t()}
      @spec download_file(Client.t(), binary | File.t(), Path.t(), non_neg_integer, keyword) ::
              {:ok, Path.t()} | {:error, Error.t()}
      def download_file(file_or_id, destination, max_bytes) do
        Nadia.FileDownload.download(Client.default(), file_or_id, destination, max_bytes, [])
      end

      @doc group: "Updates And Files"
      @doc """
      Downloads with either an explicit client or default-client options.

      See `download_file/3` for bounds, filesystem publication, adapter, and
      security behavior.
      """
      def download_file(%Client{} = client, file_or_id, destination, max_bytes) do
        Nadia.FileDownload.download(client, file_or_id, destination, max_bytes, [])
      end

      def download_file(file_or_id, destination, max_bytes, options) do
        Nadia.FileDownload.download(
          Client.default(),
          file_or_id,
          destination,
          max_bytes,
          options
        )
      end

      @doc group: "Updates And Files"
      @doc """
      Downloads with an explicit client and options.

      See `download_file/3` for bounds, filesystem publication, adapter, and
      security behavior.
      """
      def download_file(%Client{} = client, file_or_id, destination, max_bytes, options) do
        Nadia.FileDownload.download(client, file_or_id, destination, max_bytes, options)
      end

      defp file_link(%Client{file_mode: :remote} = client, file_path) do
        if Path.type(file_path) == :relative do
          {:ok, build_file_url(client, file_path)}
        else
          {:error, %Error{reason: :absolute_file_path_not_allowed}}
        end
      end

      defp file_link(%Client{file_mode: :local}, _file_path),
        do: {:error, %Error{reason: :local_file_path}}
    end
  end
end
