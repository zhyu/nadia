defmodule Nadia do
  @moduledoc """
  Provides access to Telegram Bot API.

  ## Reference
  https://core.telegram.org/bots/api#available-methods

  ## Explicit clients

  Public Bot API wrappers accept a `%Nadia.Client{}` as the first argument when
  a call should use a specific bot identity:

      client = Nadia.Client.new(token: System.fetch_env!("TELEGRAM_BOT_TOKEN"))
      Nadia.send_message(client, 123, "hello")

  Legacy application config based calls remain supported:

      Nadia.send_message(123, "hello")
  """

  @moduledoc groups: [
               "Updates And Files",
               "Messages",
               "Interactions And Editing",
               "Chats And Administration",
               "Pinned Messages",
               "Stickers",
               "Games",
               "Payments",
               "Bot Account",
               "Business",
               "Managed Bots",
               "Gifts And Verification"
             ]

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

  import Nadia.API

  @behaviour Nadia.Behaviour

  defp api_request(method), do: request(method)

  defp api_request(%Client{} = client, method), do: request(client, method, [], nil)
  defp api_request(method, options), do: request(method, options)

  defp api_request(%Client{} = client, method, options), do: request(client, method, options, nil)
  defp api_request(method, options, file_field), do: request(method, options, file_field)

  defp api_request(%Client{} = client, method, options, file_field) do
    request(client, method, options, file_field)
  end

  defp encode_permissions(permissions) when is_list(permissions) do
    permissions
    |> Map.new()
    |> reject_nil_values()
    |> Jason.encode!()
  end

  defp encode_permissions(%_{} = permissions) do
    permissions
    |> Map.from_struct()
    |> reject_nil_values()
    |> Jason.encode!()
  end

  defp encode_permissions(permissions) when is_map(permissions) do
    permissions
    |> reject_nil_values()
    |> Jason.encode!()
  end

  defp encode_permissions(permissions), do: permissions

  defp encode_json_payload(nil), do: nil
  defp encode_json_payload(payload) when is_binary(payload), do: payload

  defp encode_json_payload(payload) do
    %Nadia.InputFile.JSONPayload{value: json_payload_value(payload)}
  end

  defp encode_json_array_payload(nil), do: nil
  defp encode_json_array_payload(payload) when is_binary(payload), do: payload

  defp encode_json_array_payload(payload) when is_list(payload) do
    %Nadia.InputFile.JSONPayload{value: Enum.map(payload, &json_payload_value/1)}
  end

  defp encode_json_array_payload(payload), do: encode_json_payload(payload)

  defp json_payload_value(payload) when is_list(payload) do
    if Keyword.keyword?(payload) do
      payload
      |> Map.new()
      |> json_payload_value()
    else
      Enum.map(payload, &json_payload_value/1)
    end
  end

  defp json_payload_value(%Nadia.InputFile{} = payload), do: payload

  defp json_payload_value(%_{} = payload) do
    payload
    |> Map.from_struct()
    |> json_payload_value()
  end

  defp json_payload_value(payload) when is_map(payload) do
    payload
    |> reject_nil_values()
    |> Map.new(fn {key, value} -> {key, json_payload_value(value)} end)
  end

  defp json_payload_value(payload), do: payload

  defp encode_poll_options(params) when is_list(params) do
    Keyword.update(params, :options, nil, &encode_json_payload/1)
  end

  defp encode_poll_options(params) when is_map(params) do
    Map.update(params, :options, nil, &encode_json_payload/1)
  end

  defp do_answer_guest_query(client, guest_query_id, result, options) do
    args = [guest_query_id: guest_query_id, result: encode_inline_query_result(result)]

    if client do
      api_request(client, "answerGuestQuery", args ++ options)
    else
      api_request("answerGuestQuery", args ++ options)
    end
  end

  defp do_save_prepared_inline_message(client, user_id, result, options) do
    args = [user_id: user_id, result: encode_inline_query_result(result)]

    if client do
      api_request(client, "savePreparedInlineMessage", request_options(args, options))
    else
      api_request("savePreparedInlineMessage", request_options(args, options))
    end
  end

  defp do_answer_inline_query(client, inline_query_id, results, options) do
    encoded_results =
      results
      |> Enum.map(&inline_query_result_map/1)
      |> Jason.encode!()

    args = [inline_query_id: inline_query_id, results: encoded_results]

    if client do
      api_request(client, "answerInlineQuery", args ++ options)
    else
      api_request("answerInlineQuery", args ++ options)
    end
  end

  defp encode_inline_query_result(result) do
    result
    |> inline_query_result_map()
    |> Jason.encode!()
  end

  defp inline_query_result_map(result) do
    for {k, v} <- Map.from_struct(result), v != nil, into: %{}, do: {k, v}
  end

  defp request_options(required, options) when is_list(options), do: required ++ options

  defp request_options(required, options) when is_map(options),
    do: Map.merge(Map.new(required), options)

  defp encode_json_option(options, key) when is_list(options) do
    Keyword.update(options, key, nil, &encode_json_payload/1)
  end

  defp encode_json_option(options, key) when is_map(options) do
    Map.update(options, key, nil, &encode_json_payload/1)
  end

  defp encode_json_array_option(options, key) when is_list(options) do
    Keyword.update(options, key, nil, &encode_json_array_payload/1)
  end

  defp encode_json_array_option(options, key) when is_map(options) do
    Map.update(options, key, nil, &encode_json_array_payload/1)
  end

  defp encode_invoice_options(options) do
    options
    |> encode_json_array_option(:suggested_tip_amounts)
    |> encode_json_option(:provider_data)
    |> encode_json_option(:suggested_post_parameters)
    |> encode_json_option(:reply_parameters)
  end

  defp encode_rich_message_options(options) do
    options
    |> encode_json_option(:suggested_post_parameters)
    |> encode_json_option(:reply_parameters)
  end

  defp encode_story_options(options) do
    options
    |> encode_json_array_option(:caption_entities)
    |> encode_json_array_option(:areas)
  end

  defp encode_added_user_ids(options) do
    Keyword.update(options, :added_user_ids, nil, &Jason.encode!/1)
  end

  defp encode_message_ids(message_ids), do: Jason.encode!(message_ids)

  defp encode_reaction_option(options) do
    Keyword.update(options, :reaction, nil, &encode_reaction_types/1)
  end

  defp encode_reaction_types(nil), do: nil

  defp encode_reaction_types(reaction) when is_list(reaction) do
    reaction
    |> normalize_reaction_types()
    |> Jason.encode!()
  end

  defp encode_reaction_types(reaction) do
    [reaction]
    |> normalize_reaction_types()
    |> Jason.encode!()
  end

  defp normalize_reaction_types([]), do: []

  defp normalize_reaction_types(reaction) when is_list(reaction) do
    if Keyword.keyword?(reaction) do
      [reaction_type_map(reaction)]
    else
      Enum.map(reaction, &reaction_type_map/1)
    end
  end

  defp reaction_type_map(reaction) when is_list(reaction) do
    reaction
    |> Map.new()
    |> reject_nil_values()
  end

  defp reaction_type_map(%_{} = reaction) do
    reaction
    |> Map.from_struct()
    |> reject_nil_values()
  end

  defp reaction_type_map(reaction) when is_map(reaction) do
    reject_nil_values(reaction)
  end

  defp reject_nil_values(map) do
    for {key, value} <- map, value != nil, into: %{}, do: {key, value}
  end

  use Nadia.Methods.BotAccount
  use Nadia.Methods.GiftsAndVerification
  use Nadia.Methods.Messages
  use Nadia.Methods.Games
  use Nadia.Methods.UpdatesAndFiles
  use Nadia.Methods.Chats
  use Nadia.Methods.Business
  use Nadia.Methods.Payments
  use Nadia.Methods.ManagedBots
  use Nadia.Methods.Interactions
  use Nadia.Methods.Stickers
  use Nadia.Methods.PinnedMessages
end
