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
  defp json_payload_value(%Nadia.InputContactMessageContent{} = payload), do: payload
  defp json_payload_value(%Nadia.InputInvoiceMessageContent{} = payload), do: payload
  defp json_payload_value(%Nadia.InputLocationMessageContent{} = payload), do: payload
  defp json_payload_value(%Nadia.InputMedia{} = payload), do: payload
  defp json_payload_value(%Nadia.InputPaidMedia{} = payload), do: payload
  defp json_payload_value(%Nadia.InputPollOption{} = payload), do: payload
  defp json_payload_value(%Nadia.InputPollMedia{} = payload), do: payload
  defp json_payload_value(%Nadia.InputProfilePhoto{} = payload), do: payload
  defp json_payload_value(%Nadia.InputRichMessage{} = payload), do: payload
  defp json_payload_value(%Nadia.InputRichMessageContent{} = payload), do: payload
  defp json_payload_value(%Nadia.InputTextMessageContent{} = payload), do: payload
  defp json_payload_value(%Nadia.InputVenueMessageContent{} = payload), do: payload
  defp json_payload_value(%Nadia.LabeledPrice{} = payload), do: payload
  defp json_payload_value(%Nadia.ReactionType{} = payload), do: payload
  defp json_payload_value(%Nadia.InputSticker{} = payload), do: payload
  defp json_payload_value(%Nadia.StoryArea{} = payload), do: payload
  defp json_payload_value(%Nadia.InputStoryContent{} = payload), do: payload

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
    params
    |> encode_json_array_option(:options)
    |> encode_json_array_option(:question_entities)
    |> encode_json_array_option(:country_codes)
    |> encode_json_array_option(:correct_option_ids)
    |> encode_json_array_option(:explanation_entities)
    |> encode_json_array_option(:description_entities)
    |> encode_json_option(:media)
    |> encode_json_option(:explanation_media)
    |> encode_json_option(:reply_parameters)
  end

  defp encode_poll_options(params) when is_map(params) do
    params
    |> encode_json_array_option(:options)
    |> encode_json_array_option(:question_entities)
    |> encode_json_array_option(:country_codes)
    |> encode_json_array_option(:correct_option_ids)
    |> encode_json_array_option(:explanation_entities)
    |> encode_json_array_option(:description_entities)
    |> encode_json_option(:media)
    |> encode_json_option(:explanation_media)
    |> encode_json_option(:reply_parameters)
  end

  defp validate_poll_options(params) do
    with :ok <- validate_poll_media_option(option_value(params, :media), :description),
         :ok <- validate_poll_explanation_media(params),
         :ok <- validate_poll_option_values(params) do
      :ok
    end
  end

  defp validate_poll_explanation_media(params) do
    explanation_media = option_value(params, :explanation_media)

    if typed_poll_media?(explanation_media) do
      case option_value(params, :type) do
        type when type in ["quiz", :quiz] ->
          validate_poll_media_option(explanation_media, :explanation)

        _type ->
          {:error, {:input_poll_media, :explanation_media_requires_quiz}}
      end
    else
      :ok
    end
  end

  defp validate_poll_option_values(params) do
    options = option_value(params, :options)

    with :ok <- validate_poll_option_list(options),
         :ok <- validate_correct_option_ids(params, options) do
      :ok
    end
  end

  defp validate_poll_option_list([]),
    do: {:error, {:input_poll_option, {:option_count, 0}}}

  defp validate_poll_option_list(options) when is_list(options) do
    if Keyword.keyword?(options) do
      :ok
    else
      typed_options? = Enum.any?(options, &match?(%Nadia.InputPollOption{}, &1))
      typed_media? = Enum.any?(options, &typed_poll_media?(poll_option_media(&1)))

      cond do
        typed_options? and length(options) not in 1..12 ->
          {:error, {:input_poll_option, {:option_count, length(options)}}}

        typed_media? and length(options) not in 1..12 ->
          {:error, {:input_poll_media, {:poll_option_size, length(options)}}}

        true ->
          options
          |> Enum.with_index()
          |> Enum.reduce_while(:ok, fn {option, index}, :ok ->
            case validate_poll_option(option, index) do
              :ok -> {:cont, :ok}
              {:error, _reason} = error -> {:halt, error}
            end
          end)
      end
    end
  end

  defp validate_poll_option_list(_options), do: :ok

  defp validate_poll_option(%Nadia.InputPollOption{} = option, index) do
    case Nadia.InputPollOption.to_map(option) do
      {:ok, _map} -> :ok
      {:error, reason} -> {:error, {:input_poll_option, {:option, index, reason}}}
    end
  end

  defp validate_poll_option(option, _index) do
    validate_poll_media_option(poll_option_media(option), :option)
  end

  defp validate_correct_option_ids(params, options) when is_list(options) do
    if Keyword.keyword?(options) or
         not Enum.any?(options, &match?(%Nadia.InputPollOption{}, &1)) do
      :ok
    else
      ids = option_value(params, :correct_option_ids)
      quiz? = option_value(params, :type) in ["quiz", :quiz]

      cond do
        is_binary(ids) ->
          :ok

        quiz? and ids in [nil, []] ->
          {:error, {:input_poll_option, {:correct_option_ids, :required}}}

        is_nil(ids) ->
          :ok

        not is_list(ids) ->
          {:error, {:input_poll_option, {:correct_option_ids, :integer_list_required}}}

        not Enum.all?(ids, &is_integer/1) ->
          {:error, {:input_poll_option, {:correct_option_ids, :integer_list_required}}}

        ids != Enum.sort(ids) or length(ids) != MapSet.size(MapSet.new(ids)) ->
          {:error, {:input_poll_option, {:correct_option_ids, :not_strictly_increasing}}}

        invalid = Enum.find(ids, &(&1 < 0 or &1 >= length(options))) ->
          {:error,
           {:input_poll_option, {:correct_option_ids, {:out_of_bounds, invalid, length(options)}}}}

        true ->
          :ok
      end
    end
  end

  defp validate_correct_option_ids(_params, _options), do: :ok

  defp validate_poll_media_option(media, context) do
    if typed_poll_media?(media) do
      case Nadia.InputPollMedia.validate_context(media, context) do
        :ok -> :ok
        {:error, reason} -> {:error, {:input_poll_media, reason}}
      end
    else
      :ok
    end
  end

  defp typed_poll_media?(%Nadia.InputMedia{}), do: true
  defp typed_poll_media?(%Nadia.InputPollMedia{}), do: true
  defp typed_poll_media?(_media), do: false

  defp poll_option_media(option) when is_list(option) do
    if Keyword.keyword?(option), do: Keyword.get(option, :media), else: nil
  end

  defp poll_option_media(%_{} = option), do: option |> Map.from_struct() |> poll_option_media()

  defp poll_option_media(option) when is_map(option) do
    Map.get(option, :media, Map.get(option, "media"))
  end

  defp poll_option_media(_option), do: nil

  defp validate_rich_message(%Nadia.InputRichMessage{} = rich_message, context) do
    case Nadia.InputRichMessage.validate_context(rich_message, context) do
      :ok -> :ok
      {:error, reason} -> {:error, {:input_rich_message, reason}}
    end
  end

  defp validate_rich_message(_rich_message, _context), do: :ok

  defp validate_story_options(options) do
    case Nadia.StoryArea.validate_areas(option_value(options, :areas)) do
      :ok -> :ok
      {:error, reason} -> {:error, {:story_area, reason}}
    end
  end

  defp do_answer_guest_query(client, guest_query_id, result, options) do
    args = [guest_query_id: guest_query_id, result: encode_json_payload(result)]

    if client do
      api_request(client, "answerGuestQuery", args ++ options)
    else
      api_request("answerGuestQuery", args ++ options)
    end
  end

  defp do_save_prepared_inline_message(client, user_id, result, options) do
    args = [user_id: user_id, result: encode_json_payload(result)]

    if client do
      api_request(client, "savePreparedInlineMessage", request_options(args, options))
    else
      api_request("savePreparedInlineMessage", request_options(args, options))
    end
  end

  defp do_answer_inline_query(client, inline_query_id, results, options) do
    args = [inline_query_id: inline_query_id, results: encode_json_array_payload(results)]

    if client do
      api_request(client, "answerInlineQuery", args ++ options)
    else
      api_request("answerInlineQuery", args ++ options)
    end
  end

  defp request_options(required, options) when is_list(options), do: required ++ options

  defp request_options(required, options) when is_map(options),
    do: Map.merge(Map.new(required), options)

  defp encode_json_option(options, key) when is_list(options) do
    Keyword.update(options, key, nil, &encode_json_payload/1)
  end

  defp encode_json_option(options, key) when is_map(options) do
    update_map_option(options, key, &encode_json_payload/1)
  end

  defp encode_json_option(options, _key), do: options

  defp encode_json_array_option(options, key) when is_list(options) do
    Keyword.update(options, key, nil, &encode_json_array_payload/1)
  end

  defp encode_json_array_option(options, key) when is_map(options) do
    update_map_option(options, key, &encode_json_array_payload/1)
  end

  defp encode_json_array_option(options, _key), do: options

  defp update_map_option(options, key, encoder) do
    string_key = Atom.to_string(key)

    cond do
      Map.has_key?(options, key) -> Map.update!(options, key, encoder)
      Map.has_key?(options, string_key) -> Map.update!(options, string_key, encoder)
      true -> options
    end
  end

  defp encode_invoice_options(options) do
    options
    |> encode_json_array_option(:suggested_tip_amounts)
    |> encode_json_option(:provider_data)
    |> encode_json_option(:suggested_post_parameters)
    |> encode_json_option(:reply_parameters)
  end

  defp encode_paid_media_options(options) do
    options
    |> encode_json_array_option(:caption_entities)
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

  defp legacy_input_sticker(sticker, emojis, options) do
    emoji_list = if is_list(emojis), do: emojis, else: [emojis]

    sticker_options = []

    sticker_options =
      case option_value(options, :mask_position) do
        nil -> sticker_options
        mask_position -> Keyword.put(sticker_options, :mask_position, mask_position)
      end

    sticker_options =
      case option_value(options, :keywords) do
        nil -> sticker_options
        keywords -> Keyword.put(sticker_options, :keywords, keywords)
      end

    Nadia.InputSticker.static(sticker, emoji_list, sticker_options)
  end

  defp current_sticker_set_options(options) do
    options
    |> delete_option(:mask_position)
    |> delete_option(:keywords)
    |> rename_legacy_mask_option()
  end

  defp current_sticker_options?(options) when is_map(options), do: true

  defp current_sticker_options?(options) when is_list(options),
    do: Keyword.keyword?(options)

  defp current_sticker_options?(_options), do: false

  defp rename_legacy_mask_option(options) do
    case option_value(options, :contains_masks) do
      true -> options |> delete_option(:contains_masks) |> put_option(:sticker_type, "mask")
      _ -> delete_option(options, :contains_masks)
    end
  end

  defp option_value(options, key) when is_list(options), do: Keyword.get(options, key)

  defp option_value(options, key) when is_map(options),
    do: Map.get(options, key, Map.get(options, Atom.to_string(key)))

  defp delete_option(options, key) when is_list(options), do: Keyword.delete(options, key)
  defp delete_option(options, key) when is_map(options), do: Map.delete(options, key)

  defp put_option(options, key, value) when is_list(options), do: Keyword.put(options, key, value)
  defp put_option(options, key, value) when is_map(options), do: Map.put(options, key, value)

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
