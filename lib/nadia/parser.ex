defmodule Nadia.Parser do
  @moduledoc """
  Provides parser logics for API results.
  """

  alias Nadia.Model.{
    AffiliateInfo,
    BotAccessSettings,
    BotCommand,
    BotDescription,
    BotName,
    BotShortDescription,
    BusinessBotRights,
    BusinessConnection,
    BusinessIntro,
    BusinessLocation,
    BusinessMessagesDeleted,
    BusinessOpeningHours,
    BusinessOpeningHoursInterval,
    ForumTopic,
    GameHighScore,
    Gift,
    GiftBackground,
    Gifts,
    User,
    Chat,
    ChatInviteLink,
    ChatBoost,
    ChatBoostAdded,
    ChatBoostRemoved,
    ChatBoostSource,
    ChatBoostSourceGiftCode,
    ChatBoostSourceGiveaway,
    ChatBoostSourcePremium,
    ChatBoostUpdated,
    ChatAdministratorRights,
    ChatMember,
    Checklist,
    ChecklistTask,
    Message,
    MenuButton,
    MenuButtonCommands,
    MenuButtonDefault,
    MenuButtonWebApp,
    ChatPhoto,
    PhotoSize,
    Audio,
    Document,
    InlineQuery,
    ChosenInlineResult,
    MessageEntity,
    ManagedBotCreated,
    ManagedBotUpdated,
    MessageId,
    MessageReactionCountUpdated,
    MessageReactionUpdated,
    OwnedGift,
    OwnedGiftRegular,
    OwnedGifts,
    OwnedGiftUnique,
    PaidMedia,
    PaidMediaInfo,
    PaidMediaLivePhoto,
    PaidMediaPhoto,
    PaidMediaPreview,
    PaidMediaPurchased,
    PaidMediaVideo,
    Poll,
    PollAnswer,
    PollMedia,
    PollOption,
    PollOptionAdded,
    PollOptionDeleted,
    PreparedInlineMessage,
    PreparedKeyboardButton,
    ReactionCount,
    ReactionType,
    RevenueWithdrawalState,
    RevenueWithdrawalStateFailed,
    RevenueWithdrawalStatePending,
    RevenueWithdrawalStateSucceeded,
    SentGuestMessage,
    SentWebAppMessage,
    StarAmount,
    StarTransaction,
    StarTransactions,
    UniqueGift,
    UniqueGiftBackdrop,
    UniqueGiftBackdropColors,
    UniqueGiftColors,
    UniqueGiftModel,
    UniqueGiftSymbol,
    TransactionPartner,
    TransactionPartnerAffiliateProgram,
    TransactionPartnerChat,
    TransactionPartnerFragment,
    TransactionPartnerOther,
    TransactionPartnerTelegramAds,
    TransactionPartnerTelegramApi,
    TransactionPartnerUser,
    UserChatBoosts,
    UserProfileAudios,
    WebhookInfo
  }

  alias Nadia.Model.{Video, Voice, Contact, Location, Venue, Update, File, CallbackQuery}
  alias Nadia.Model.UserProfilePhotos
  alias Nadia.Model.{Sticker, StickerSet}

  @doc """
  parse `result` field of decoded API response json.
  Args:
  * `result` - `result` field of decoded API response json
  * `method` - name of API method
  """
  def parse_result(result, method) do
    case method do
      "getMe" -> parse(User, result)
      "sendChatAction" -> result
      "getUserProfilePhotos" -> parse(UserProfilePhotos, result)
      "getUpdates" -> parse(:updates, result)
      "setWebhook" -> result
      "deleteWebhook" -> result
      "getWebhookInfo" -> parse(WebhookInfo, result)
      "getFile" -> parse(File, result)
      "getChat" -> parse(Chat, result)
      "exportChatInviteLink" -> result
      "createChatInviteLink" -> parse(ChatInviteLink, result)
      "editChatInviteLink" -> parse(ChatInviteLink, result)
      "createChatSubscriptionInviteLink" -> parse(ChatInviteLink, result)
      "editChatSubscriptionInviteLink" -> parse(ChatInviteLink, result)
      "revokeChatInviteLink" -> parse(ChatInviteLink, result)
      "getChatMember" -> parse(ChatMember, result)
      "getChatAdministrators" -> parse(:chat_members, result)
      "getChatMemberCount" -> result
      "getStickerSet" -> parse(StickerSet, result)
      "getCustomEmojiStickers" -> parse(:stickers, result)
      "uploadStickerFile" -> parse(File, result)
      "getForumTopicIconStickers" -> parse(:stickers, result)
      "createForumTopic" -> parse(ForumTopic, result)
      "sendMediaGroup" -> parse(:messages, result)
      "sendPaidMedia" -> parse(Message, result)
      "stopPoll" -> parse(Poll, result)
      "getUserChatBoosts" -> parse(UserChatBoosts, result)
      "getBusinessConnection" -> parse(BusinessConnection, result)
      "answerGuestQuery" -> parse(SentGuestMessage, result)
      "answerWebAppQuery" -> parse(SentWebAppMessage, result)
      "savePreparedInlineMessage" -> parse(PreparedInlineMessage, result)
      "savePreparedKeyboardButton" -> parse(PreparedKeyboardButton, result)
      "getAvailableGifts" -> parse(Gifts, result)
      "getUserGifts" -> parse(OwnedGifts, result)
      "getChatGifts" -> parse(OwnedGifts, result)
      "getBusinessAccountGifts" -> parse(OwnedGifts, result)
      "getManagedBotToken" -> result
      "replaceManagedBotToken" -> result
      "getManagedBotAccessSettings" -> parse(BotAccessSettings, result)
      "getUserPersonalChatMessages" -> parse(:messages, result)
      "getUserProfileAudios" -> parse(UserProfileAudios, result)
      "getMyStarBalance" -> parse(StarAmount, result)
      "getBusinessAccountStarBalance" -> parse(StarAmount, result)
      "getStarTransactions" -> parse(StarTransactions, result)
      "getGameHighScores" -> parse(:game_high_scores, result)
      "getMyCommands" -> parse(:bot_commands, result)
      "getMyName" -> parse(BotName, result)
      "getMyDescription" -> parse(BotDescription, result)
      "getMyShortDescription" -> parse(BotShortDescription, result)
      "getChatMenuButton" -> parse_menu_button(result)
      "getMyDefaultAdministratorRights" -> parse(ChatAdministratorRights, result)
      "copyMessage" -> parse(MessageId, result)
      "copyMessages" -> parse(:message_ids, result)
      "forwardMessages" -> parse(:message_ids, result)
      _ -> parse(Message, result)
    end
  end

  @keys_of_message [
    :message,
    :reply_to_message,
    :channel_post,
    :edited_message,
    :edited_channel_post,
    :business_message,
    :edited_business_message,
    :guest_message,
    :pinned_message
  ]

  @keys_of_inline_query [:inline_query]
  @keys_of_choosen_inline_result [:chosen_inline_result]
  @keys_of_photo [:photo, :new_chat_photo]
  @keys_of_user [
    :from,
    :forward_from,
    :new_chat_participant,
    :new_chat_member,
    :left_chat_participant,
    :left_chat_member,
    :via_bot,
    :sender_business_bot,
    :guest_bot_caller_user,
    :added_by_user
  ]

  @keys_of_chat [
    :chat,
    :forward_from_chat,
    :sender_chat,
    :guest_bot_caller_chat,
    :added_by_chat,
    :voter_chat,
    :actor_chat
  ]

  @keys_of_message_entities [
    :entities,
    :caption_entities,
    :text_entities,
    :title_entities,
    :question_entities,
    :explanation_entities,
    :description_entities,
    :option_text_entities
  ]

  defp parse(:photo, l) when is_list(l), do: Enum.map(l, &parse(PhotoSize, &1))
  defp parse(:photo, p), do: parse(ChatPhoto, p)
  defp parse(:photos, l) when is_list(l), do: Enum.map(l, &parse(:photo, &1))
  defp parse(:updates, l) when is_list(l), do: Enum.map(l, &parse(Update, &1))
  defp parse(:chat_members, l) when is_list(l), do: Enum.map(l, &parse(ChatMember, &1))
  defp parse(:messages, l) when is_list(l), do: Enum.map(l, &parse(Message, &1))
  defp parse(:message_ids, l) when is_list(l), do: Enum.map(l, &parse(MessageId, &1))
  defp parse(:stickers, l) when is_list(l), do: Enum.map(l, &parse(Sticker, &1))
  defp parse(:bot_commands, l) when is_list(l), do: Enum.map(l, &parse(BotCommand, &1))
  defp parse(:game_high_scores, l) when is_list(l), do: Enum.map(l, &parse(GameHighScore, &1))

  defp parse(type, val) when is_map(val) do
    fields = struct_fields(type)

    entries =
      val
      |> Enum.flat_map(&known_struct_entry(&1, fields))
      |> Enum.map(&parse(type, &1))

    struct(type, entries)
  end

  defp parse(StarTransactions, {:transactions, val}) when is_list(val),
    do: {:transactions, Enum.map(val, &parse(StarTransaction, &1))}

  defp parse(StarTransaction, {:source, val}), do: {:source, parse_transaction_partner(val)}
  defp parse(StarTransaction, {:receiver, val}), do: {:receiver, parse_transaction_partner(val)}

  defp parse(TransactionPartnerUser, {:user, val}), do: {:user, parse(User, val)}

  defp parse(TransactionPartnerUser, {:affiliate, val}),
    do: {:affiliate, parse(AffiliateInfo, val)}

  defp parse(TransactionPartnerUser, {:paid_media, val}) when is_list(val),
    do: {:paid_media, Enum.map(val, &parse_paid_media/1)}

  defp parse(TransactionPartnerUser, {:gift, val}), do: {:gift, parse(Gift, val)}

  defp parse(TransactionPartnerChat, {:chat, val}), do: {:chat, parse(Chat, val)}
  defp parse(TransactionPartnerChat, {:gift, val}), do: {:gift, parse(Gift, val)}

  defp parse(TransactionPartnerAffiliateProgram, {:sponsor_user, val}),
    do: {:sponsor_user, parse(User, val)}

  defp parse(TransactionPartnerFragment, {:withdrawal_state, val}),
    do: {:withdrawal_state, parse_revenue_withdrawal_state(val)}

  defp parse(AffiliateInfo, {:affiliate_user, val}), do: {:affiliate_user, parse(User, val)}
  defp parse(AffiliateInfo, {:affiliate_chat, val}), do: {:affiliate_chat, parse(Chat, val)}

  defp parse(Poll, {:options, val}) when is_list(val),
    do: {:options, Enum.map(val, &parse(PollOption, &1))}

  defp parse(Poll, {:media, val}), do: {:media, parse(PollMedia, val)}
  defp parse(Poll, {:explanation_media, val}), do: {:explanation_media, parse(PollMedia, val)}
  defp parse(PollOption, {:media, val}), do: {:media, parse(PollMedia, val)}
  defp parse(PollOptionAdded, {:poll_message, val}), do: {:poll_message, parse(Message, val)}
  defp parse(PollOptionDeleted, {:poll_message, val}), do: {:poll_message, parse(Message, val)}

  defp parse(ChatBoost, {:source, val}), do: {:source, parse_chat_boost_source(val)}
  defp parse(ChatBoostUpdated, {:boost, val}), do: {:boost, parse(ChatBoost, val)}
  defp parse(ChatBoostRemoved, {:source, val}), do: {:source, parse_chat_boost_source(val)}

  defp parse(UserChatBoosts, {:boosts, val}) when is_list(val),
    do: {:boosts, Enum.map(val, &parse(ChatBoost, &1))}

  defp parse(Message, {:paid_media, val}), do: {:paid_media, parse(PaidMediaInfo, val)}

  defp parse(Update, {:purchased_paid_media, val}),
    do: {:purchased_paid_media, parse(PaidMediaPurchased, val)}

  defp parse(PaidMediaInfo, {:paid_media, val}) when is_list(val),
    do: {:paid_media, Enum.map(val, &parse_paid_media/1)}

  defp parse(PaidMediaPhoto, {:photo, val}) when is_list(val),
    do: {:photo, Enum.map(val, &parse(PhotoSize, &1))}

  defp parse(PaidMediaVideo, {:video, val}), do: {:video, parse(Video, val)}
  defp parse(PaidMediaLivePhoto, {:live_photo, val}), do: {:live_photo, val}

  defp parse(BusinessConnection, {:rights, val}), do: {:rights, parse(BusinessBotRights, val)}

  defp parse(BusinessOpeningHours, {:opening_hours, val}) when is_list(val),
    do: {:opening_hours, Enum.map(val, &parse(BusinessOpeningHoursInterval, &1))}

  defp parse(ManagedBotCreated, {:bot, val}), do: {:bot, parse(User, val)}
  defp parse(ManagedBotUpdated, {:user, val}), do: {:user, parse(User, val)}
  defp parse(ManagedBotUpdated, {:bot, val}), do: {:bot, parse(User, val)}

  defp parse(ChatInviteLink, {:creator, val}), do: {:creator, parse(User, val)}

  defp parse(GameHighScore, {:user, val}), do: {:user, parse(User, val)}

  defp parse(BotAccessSettings, {:added_users, val}) when is_list(val),
    do: {:added_users, Enum.map(val, &parse(User, &1))}

  defp parse(Gifts, {:gifts, val}) when is_list(val),
    do: {:gifts, Enum.map(val, &parse(Gift, &1))}

  defp parse(Gift, {:sticker, val}), do: {:sticker, parse(Sticker, val)}
  defp parse(Gift, {:background, val}), do: {:background, parse(GiftBackground, val)}
  defp parse(Gift, {:publisher_chat, val}), do: {:publisher_chat, parse(Chat, val)}

  defp parse(UniqueGiftModel, {:sticker, val}), do: {:sticker, parse(Sticker, val)}
  defp parse(UniqueGiftSymbol, {:sticker, val}), do: {:sticker, parse(Sticker, val)}

  defp parse(UniqueGiftBackdrop, {:colors, val}),
    do: {:colors, parse(UniqueGiftBackdropColors, val)}

  defp parse(UniqueGift, {:model, val}), do: {:model, parse(UniqueGiftModel, val)}
  defp parse(UniqueGift, {:symbol, val}), do: {:symbol, parse(UniqueGiftSymbol, val)}
  defp parse(UniqueGift, {:backdrop, val}), do: {:backdrop, parse(UniqueGiftBackdrop, val)}
  defp parse(UniqueGift, {:colors, val}), do: {:colors, parse(UniqueGiftColors, val)}
  defp parse(UniqueGift, {:publisher_chat, val}), do: {:publisher_chat, parse(Chat, val)}

  defp parse(OwnedGifts, {:gifts, val}) when is_list(val),
    do: {:gifts, Enum.map(val, &parse_owned_gift/1)}

  defp parse(OwnedGiftRegular, {:gift, val}), do: {:gift, parse(Gift, val)}
  defp parse(OwnedGiftRegular, {:sender_user, val}), do: {:sender_user, parse(User, val)}

  defp parse(OwnedGiftRegular, {:entities, val}) when is_list(val),
    do: {:entities, Enum.map(val, &parse(MessageEntity, &1))}

  defp parse(OwnedGiftUnique, {:gift, val}), do: {:gift, parse(UniqueGift, val)}
  defp parse(OwnedGiftUnique, {:sender_user, val}), do: {:sender_user, parse(User, val)}

  defp parse(UserProfileAudios, {:audios, val}) when is_list(val),
    do: {:audios, Enum.map(val, &parse(Audio, &1))}

  defp parse(Message, {:checklist, val}), do: {:checklist, parse(Checklist, val)}

  defp parse(Checklist, {:tasks, val}) when is_list(val),
    do: {:tasks, Enum.map(val, &parse(ChecklistTask, &1))}

  defp parse(ChecklistTask, {:completed_by_user, val}),
    do: {:completed_by_user, parse(User, val)}

  defp parse(ChecklistTask, {:completed_by_chat, val}),
    do: {:completed_by_chat, parse(Chat, val)}

  defp parse(ReactionCount, {:type, val}), do: {:type, parse(ReactionType, val)}

  defp parse(MessageReactionUpdated, {:old_reaction, val}) when is_list(val),
    do: {:old_reaction, Enum.map(val, &parse(ReactionType, &1))}

  defp parse(MessageReactionUpdated, {:new_reaction, val}) when is_list(val),
    do: {:new_reaction, Enum.map(val, &parse(ReactionType, &1))}

  defp parse(MessageReactionCountUpdated, {:reactions, val}) when is_list(val),
    do: {:reactions, Enum.map(val, &parse(ReactionCount, &1))}

  defp parse(_type, entry), do: parse(entry)

  defp parse({:audio, val}), do: {:audio, parse(Audio, val)}
  defp parse({:video, val}), do: {:video, parse(Video, val)}
  defp parse({:voice, val}), do: {:voice, parse(Voice, val)}
  defp parse({:sticker, val}), do: {:sticker, parse(Sticker, val)}
  defp parse({:document, val}), do: {:document, parse(Document, val)}
  defp parse({:contact, val}), do: {:contact, parse(Contact, val)}
  defp parse({:location, val}), do: {:location, parse(Location, val)}
  defp parse({:venue, val}), do: {:venue, parse(Venue, val)}
  defp parse({:thumb, val}), do: {:thumb, parse(PhotoSize, val)}
  defp parse({:photos, val}), do: {:photos, parse(:photos, val)}
  defp parse({:user, val}), do: {:user, parse(User, val)}
  defp parse({:poll, val}), do: {:poll, parse(Poll, val)}
  defp parse({:poll_answer, val}), do: {:poll_answer, parse(PollAnswer, val)}
  defp parse({:poll_option_added, val}), do: {:poll_option_added, parse(PollOptionAdded, val)}

  defp parse({:poll_option_deleted, val}),
    do: {:poll_option_deleted, parse(PollOptionDeleted, val)}

  defp parse({:business_connection, val}),
    do: {:business_connection, parse(BusinessConnection, val)}

  defp parse({:deleted_business_messages, val}),
    do: {:deleted_business_messages, parse(BusinessMessagesDeleted, val)}

  defp parse({:business_intro, val}), do: {:business_intro, parse(BusinessIntro, val)}
  defp parse({:business_location, val}), do: {:business_location, parse(BusinessLocation, val)}

  defp parse({:business_opening_hours, val}),
    do: {:business_opening_hours, parse(BusinessOpeningHours, val)}

  defp parse({:boost_added, val}), do: {:boost_added, parse(ChatBoostAdded, val)}
  defp parse({:chat_boost, val}), do: {:chat_boost, parse(ChatBoostUpdated, val)}

  defp parse({:managed_bot_created, val}),
    do: {:managed_bot_created, parse(ManagedBotCreated, val)}

  defp parse({:managed_bot, val}), do: {:managed_bot, parse(ManagedBotUpdated, val)}

  defp parse({:removed_chat_boost, val}),
    do: {:removed_chat_boost, parse(ChatBoostRemoved, val)}

  defp parse({:message_reaction, val}),
    do: {:message_reaction, parse(MessageReactionUpdated, val)}

  defp parse({:message_reaction_count, val}),
    do: {:message_reaction_count, parse(MessageReactionCountUpdated, val)}

  defp parse({:stickers, val}) when is_list(val), do: {:stickers, parse(:stickers, val)}

  defp parse({:new_chat_members, val}) when is_list(val),
    do: {:new_chat_members, Enum.map(val, &parse(User, &1))}

  defp parse({:callback_query, val}), do: {:callback_query, parse(CallbackQuery, val)}
  defp parse({key, val}) when key in @keys_of_chat, do: {key, parse(Chat, val)}
  defp parse({key, val}) when key in @keys_of_photo, do: {key, parse(:photo, val)}
  defp parse({key, val}) when key in @keys_of_user, do: {key, parse(User, val)}
  defp parse({key, val}) when key in @keys_of_message, do: {key, parse(Message, val)}

  defp parse({key, val}) when key in @keys_of_message_entities and is_list(val),
    do: {key, Enum.map(val, &parse(MessageEntity, &1))}

  defp parse({key, val}) when key in @keys_of_inline_query, do: {key, parse(InlineQuery, val)}

  defp parse({key, val}) when key in @keys_of_choosen_inline_result,
    do: {key, parse(ChosenInlineResult, val)}

  defp parse(others), do: others

  defp parse_chat_boost_source(%{} = val) do
    case Map.get(val, :source) || Map.get(val, "source") do
      "premium" -> parse(ChatBoostSourcePremium, val)
      "gift_code" -> parse(ChatBoostSourceGiftCode, val)
      "giveaway" -> parse(ChatBoostSourceGiveaway, val)
      _ -> parse(ChatBoostSource, val)
    end
  end

  defp parse_chat_boost_source(val), do: val

  defp parse_paid_media(%{} = val) do
    case Map.get(val, :type) || Map.get(val, "type") do
      "photo" -> parse(PaidMediaPhoto, val)
      "preview" -> parse(PaidMediaPreview, val)
      "video" -> parse(PaidMediaVideo, val)
      "live_photo" -> parse(PaidMediaLivePhoto, val)
      _ -> parse(PaidMedia, val)
    end
  end

  defp parse_paid_media(val), do: val

  defp parse_transaction_partner(%{} = val) do
    case Map.get(val, :type) || Map.get(val, "type") do
      "user" -> parse(TransactionPartnerUser, val)
      "chat" -> parse(TransactionPartnerChat, val)
      "affiliate_program" -> parse(TransactionPartnerAffiliateProgram, val)
      "fragment" -> parse(TransactionPartnerFragment, val)
      "telegram_ads" -> parse(TransactionPartnerTelegramAds, val)
      "telegram_api" -> parse(TransactionPartnerTelegramApi, val)
      "other" -> parse(TransactionPartnerOther, val)
      _ -> parse(TransactionPartner, val)
    end
  end

  defp parse_transaction_partner(val), do: val

  defp parse_revenue_withdrawal_state(%{} = val) do
    case Map.get(val, :type) || Map.get(val, "type") do
      "pending" -> parse(RevenueWithdrawalStatePending, val)
      "succeeded" -> parse(RevenueWithdrawalStateSucceeded, val)
      "failed" -> parse(RevenueWithdrawalStateFailed, val)
      _ -> parse(RevenueWithdrawalState, val)
    end
  end

  defp parse_revenue_withdrawal_state(val), do: val

  defp parse_owned_gift(%{} = val) do
    case Map.get(val, :type) || Map.get(val, "type") do
      "regular" -> parse(OwnedGiftRegular, val)
      "unique" -> parse(OwnedGiftUnique, val)
      _ -> parse(OwnedGift, val)
    end
  end

  defp parse_owned_gift(val), do: val

  defp parse_menu_button(%{} = val) do
    case Map.get(val, :type) || Map.get(val, "type") do
      "commands" -> parse(MenuButtonCommands, val)
      "web_app" -> parse(MenuButtonWebApp, val)
      "default" -> parse(MenuButtonDefault, val)
      _ -> parse(MenuButton, val)
    end
  end

  defp parse_menu_button(val), do: val

  defp struct_fields(type) do
    type
    |> struct()
    |> Map.keys()
    |> Enum.reject(&(&1 == :__struct__))
  end

  defp known_struct_entry({key, val}, fields) when is_atom(key) do
    if key in fields, do: [{key, val}], else: []
  end

  defp known_struct_entry({key, val}, fields) when is_binary(key) do
    case Enum.find(fields, &(Atom.to_string(&1) == key)) do
      nil -> []
      field -> [{field, val}]
    end
  end
end
