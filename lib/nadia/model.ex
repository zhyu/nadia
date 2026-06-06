defmodule Nadia.Model do
  @moduledoc """
  Types used in Telegram Bot API.

  ## Reference
  https://core.telegram.org/bots/api#available-types
  """

  defmodule User do
    defstruct id: nil,
              is_bot: nil,
              first_name: nil,
              last_name: nil,
              username: nil,
              language_code: nil,
              is_premium: nil,
              added_to_attachment_menu: nil,
              can_join_groups: nil,
              can_read_all_group_messages: nil,
              supports_guest_queries: nil,
              supports_inline_queries: nil,
              can_connect_to_business: nil,
              has_main_web_app: nil,
              has_topics_enabled: nil,
              allows_users_to_create_topics: nil,
              can_manage_bots: nil

    @type t :: %User{
            id: integer,
            is_bot: boolean,
            first_name: binary,
            last_name: binary,
            username: binary,
            language_code: binary,
            is_premium: boolean,
            added_to_attachment_menu: boolean,
            can_join_groups: boolean,
            can_read_all_group_messages: boolean,
            supports_guest_queries: boolean,
            supports_inline_queries: boolean,
            can_connect_to_business: boolean,
            has_main_web_app: boolean,
            has_topics_enabled: boolean,
            allows_users_to_create_topics: boolean,
            can_manage_bots: boolean
          }
  end

  defmodule ChatPhoto do
    defstruct small_file_id: nil, big_file_id: nil
    @type t :: %ChatPhoto{small_file_id: binary, big_file_id: binary}
  end

  defmodule Chat do
    defstruct id: nil,
              type: nil,
              title: nil,
              username: nil,
              first_name: nil,
              last_name: nil,
              photo: nil,
              business_intro: nil,
              business_location: nil,
              business_opening_hours: nil

    @type t :: %Chat{
            id: integer,
            type: binary,
            title: binary,
            username: binary,
            first_name: binary,
            last_name: binary,
            photo: ChatPhoto.t(),
            business_intro: BusinessIntro.t(),
            business_location: BusinessLocation.t(),
            business_opening_hours: BusinessOpeningHours.t()
          }
  end

  defmodule PhotoSize do
    defstruct file_id: nil, file_unique_id: nil, width: nil, height: nil, file_size: nil

    @type t :: %PhotoSize{
            file_id: binary,
            file_unique_id: binary,
            width: integer,
            height: integer,
            file_size: integer
          }
  end

  defmodule Audio do
    defstruct file_id: nil,
              duration: nil,
              performer: nil,
              title: nil,
              mime_type: nil,
              file_size: nil

    @type t :: %Audio{
            file_id: binary,
            duration: integer,
            performer: binary,
            title: binary,
            mime_type: binary,
            file_size: integer
          }
  end

  defmodule Document do
    defstruct file_id: nil, thumb: nil, file_name: nil, mime_type: nil, file_size: nil

    @type t :: %Document{
            file_id: binary,
            thumb: PhotoSize.t(),
            file_name: binary,
            mime_type: binary,
            file_size: integer
          }
  end

  defmodule Sticker do
    defstruct file_id: nil,
              width: nil,
              height: nil,
              thumb: nil,
              emoji: nil,
              set_name: nil,
              mask_position: nil,
              file_size: nil

    @type t :: %Sticker{
            file_id: binary,
            width: integer,
            height: integer,
            thumb: PhotoSize.t(),
            emoji: binary,
            set_name: binary,
            mask_position: MaskPosition.t(),
            file_size: integer
          }
  end

  defmodule StickerSet do
    defstruct name: nil, title: nil, contains_masks: false, stickers: []

    @type t :: %StickerSet{
            name: binary,
            title: binary,
            contains_masks: boolean,
            stickers: [Sticker.t()]
          }
  end

  defmodule ForumTopic do
    defstruct message_thread_id: nil,
              name: nil,
              icon_color: nil,
              icon_custom_emoji_id: nil,
              is_name_implicit: nil

    @type t :: %ForumTopic{
            message_thread_id: integer,
            name: binary,
            icon_color: integer,
            icon_custom_emoji_id: binary,
            is_name_implicit: boolean
          }
  end

  defmodule MaskPosition do
    defstruct point: nil, x_shift: nil, y_shift: nil, scale: nil

    @type t :: %MaskPosition{
            point: binary,
            x_shift: float,
            y_shift: float,
            scale: float
          }
  end

  defmodule Video do
    defstruct file_id: nil,
              width: nil,
              height: nil,
              duration: nil,
              thumb: nil,
              mime_type: nil,
              file_size: nil

    @type t :: %Video{
            file_id: binary,
            width: integer,
            height: integer,
            duration: integer,
            thumb: PhotoSize.t(),
            mime_type: binary,
            file_size: integer
          }
  end

  defmodule Voice do
    defstruct file_id: nil, duration: nil, mime_type: nil, file_size: nil
    @type t :: %Voice{file_id: binary, duration: integer, mime_type: binary, file_size: integer}
  end

  defmodule Contact do
    defstruct phone_number: nil, first_name: nil, last_name: nil, user_id: nil

    @type t :: %Contact{
            phone_number: binary,
            first_name: binary,
            last_name: binary,
            user_id: integer
          }
  end

  defmodule Location do
    defstruct latitude: nil, longitude: nil
    @type t :: %Location{latitude: float, longitude: float}
  end

  defmodule Venue do
    defstruct location: nil, title: nil, address: nil, foursquare_id: nil

    @type t :: %Venue{
            location: Location.t(),
            title: binary,
            address: binary,
            foursquare_id: binary
          }
  end

  defmodule BusinessIntro do
    defstruct title: nil, message: nil, sticker: nil

    @type t :: %BusinessIntro{
            title: binary,
            message: binary,
            sticker: Sticker.t()
          }
  end

  defmodule BusinessLocation do
    defstruct address: nil, location: nil

    @type t :: %BusinessLocation{
            address: binary,
            location: Location.t()
          }
  end

  defmodule BusinessOpeningHoursInterval do
    defstruct opening_minute: nil, closing_minute: nil

    @type t :: %BusinessOpeningHoursInterval{
            opening_minute: integer,
            closing_minute: integer
          }
  end

  defmodule BusinessOpeningHours do
    defstruct time_zone_name: nil, opening_hours: []

    @type t :: %BusinessOpeningHours{
            time_zone_name: binary,
            opening_hours: [BusinessOpeningHoursInterval.t()]
          }
  end

  defmodule Message do
    defstruct message_id: nil,
              message_thread_id: nil,
              from: nil,
              sender_chat: nil,
              sender_boost_count: nil,
              sender_business_bot: nil,
              sender_tag: nil,
              date: nil,
              guest_query_id: nil,
              business_connection_id: nil,
              chat: nil,
              forward_from: nil,
              forward_from_chat: nil,
              forward_origin: nil,
              forward_date: nil,
              reply_to_message: nil,
              external_reply: nil,
              quote: nil,
              reply_to_story: nil,
              reply_to_checklist_task_id: nil,
              reply_to_poll_option_id: nil,
              via_bot: nil,
              guest_bot_caller_user: nil,
              guest_bot_caller_chat: nil,
              edit_date: nil,
              has_protected_content: nil,
              is_topic_message: nil,
              is_automatic_forward: nil,
              is_from_offline: nil,
              is_paid_post: nil,
              media_group_id: nil,
              author_signature: nil,
              paid_star_count: nil,
              text: nil,
              entities: nil,
              link_preview_options: nil,
              suggested_post_info: nil,
              effect_id: nil,
              animation: nil,
              audio: nil,
              document: nil,
              live_photo: nil,
              paid_media: nil,
              photo: [],
              story: nil,
              sticker: nil,
              video: nil,
              video_note: nil,
              voice: nil,
              caption: nil,
              caption_entities: nil,
              show_caption_above_media: nil,
              has_media_spoiler: nil,
              checklist: nil,
              contact: nil,
              dice: nil,
              game: nil,
              poll: nil,
              poll_option_added: nil,
              poll_option_deleted: nil,
              location: nil,
              venue: nil,
              boost_added: nil,
              managed_bot_created: nil,
              new_chat_member: nil,
              new_chat_members: [],
              left_chat_member: nil,
              chat_owner_left: nil,
              chat_owner_changed: nil,
              new_chat_title: nil,
              new_chat_photo: [],
              delete_chat_photo: nil,
              group_chat_created: nil,
              supergroup_chat_created: nil,
              channel_chat_created: nil,
              migrate_to_chat_id: nil,
              migrate_from_chat_id: nil,
              pinned_message: nil,
              reply_markup: nil,
              web_app_data: nil

    @type t :: %Message{
            message_id: integer,
            message_thread_id: integer,
            from: User.t(),
            sender_chat: Chat.t(),
            sender_boost_count: integer,
            sender_business_bot: User.t(),
            sender_tag: binary,
            date: integer,
            guest_query_id: binary,
            business_connection_id: binary,
            chat: Chat.t(),
            forward_from: User.t(),
            forward_from_chat: Chat.t(),
            forward_origin: any,
            forward_date: integer,
            reply_to_message: Message.t(),
            external_reply: any,
            quote: any,
            reply_to_story: any,
            reply_to_checklist_task_id: integer,
            reply_to_poll_option_id: binary,
            via_bot: User.t(),
            guest_bot_caller_user: User.t(),
            guest_bot_caller_chat: Chat.t(),
            edit_date: integer,
            has_protected_content: boolean,
            is_topic_message: boolean,
            is_automatic_forward: boolean,
            is_from_offline: boolean,
            is_paid_post: boolean,
            media_group_id: binary,
            author_signature: binary,
            paid_star_count: integer,
            text: binary,
            entities: [MessageEntity.t()],
            link_preview_options: any,
            suggested_post_info: any,
            effect_id: binary,
            animation: any,
            audio: Audio.t(),
            document: Document.t(),
            live_photo: any,
            paid_media: PaidMediaInfo.t(),
            photo: [PhotoSize.t()],
            story: any,
            sticker: any,
            video: any,
            video_note: any,
            voice: any,
            caption: binary,
            caption_entities: [MessageEntity.t()],
            show_caption_above_media: boolean,
            has_media_spoiler: boolean,
            checklist: any,
            contact: any,
            dice: any,
            game: any,
            poll: Poll.t(),
            poll_option_added: PollOptionAdded.t(),
            poll_option_deleted: PollOptionDeleted.t(),
            location: any,
            venue: any,
            boost_added: ChatBoostAdded.t(),
            managed_bot_created: ManagedBotCreated.t(),
            new_chat_member: User.t(),
            new_chat_members: [User.t()],
            left_chat_member: User.t(),
            chat_owner_left: any,
            chat_owner_changed: any,
            new_chat_title: binary,
            new_chat_photo: [PhotoSize.t()],
            delete_chat_photo: atom,
            group_chat_created: atom,
            supergroup_chat_created: atom,
            channel_chat_created: atom,
            migrate_to_chat_id: integer,
            migrate_from_chat_id: integer,
            pinned_message: Message.t(),
            reply_markup: any,
            web_app_data: any
          }
  end

  defmodule MessageId do
    defstruct message_id: nil

    @type t :: %MessageId{message_id: integer}
  end

  defmodule PaidMediaInfo do
    defstruct star_count: nil, paid_media: []

    @type t :: %PaidMediaInfo{
            star_count: integer,
            paid_media: [PaidMedia.t()]
          }
  end

  defmodule PaidMedia do
    defstruct type: nil

    @type t ::
            %PaidMedia{type: binary}
            | PaidMediaPhoto.t()
            | PaidMediaPreview.t()
            | PaidMediaVideo.t()
            | PaidMediaLivePhoto.t()
  end

  defmodule PaidMediaPhoto do
    defstruct type: nil, photo: []

    @type t :: %PaidMediaPhoto{
            type: binary,
            photo: [PhotoSize.t()]
          }
  end

  defmodule PaidMediaPreview do
    defstruct type: nil, width: nil, height: nil, duration: nil

    @type t :: %PaidMediaPreview{
            type: binary,
            width: integer,
            height: integer,
            duration: integer
          }
  end

  defmodule PaidMediaVideo do
    defstruct type: nil, video: nil

    @type t :: %PaidMediaVideo{
            type: binary,
            video: Video.t()
          }
  end

  defmodule PaidMediaLivePhoto do
    defstruct type: nil, live_photo: nil

    @type t :: %PaidMediaLivePhoto{
            type: binary,
            live_photo: any
          }
  end

  defmodule PaidMediaPurchased do
    defstruct from: nil, paid_media_payload: nil

    @type t :: %PaidMediaPurchased{
            from: User.t(),
            paid_media_payload: binary
          }
  end

  defmodule BusinessBotRights do
    defstruct can_reply: nil,
              can_read_messages: nil,
              can_delete_sent_messages: nil,
              can_delete_all_messages: nil,
              can_edit_name: nil,
              can_edit_bio: nil,
              can_edit_profile_photo: nil,
              can_edit_username: nil,
              can_change_gift_settings: nil,
              can_view_gifts_and_stars: nil,
              can_convert_gifts_to_stars: nil,
              can_transfer_and_upgrade_gifts: nil,
              can_transfer_stars: nil,
              can_manage_stories: nil

    @type t :: %BusinessBotRights{
            can_reply: boolean,
            can_read_messages: boolean,
            can_delete_sent_messages: boolean,
            can_delete_all_messages: boolean,
            can_edit_name: boolean,
            can_edit_bio: boolean,
            can_edit_profile_photo: boolean,
            can_edit_username: boolean,
            can_change_gift_settings: boolean,
            can_view_gifts_and_stars: boolean,
            can_convert_gifts_to_stars: boolean,
            can_transfer_and_upgrade_gifts: boolean,
            can_transfer_stars: boolean,
            can_manage_stories: boolean
          }
  end

  defmodule BusinessConnection do
    defstruct id: nil,
              user: nil,
              user_chat_id: nil,
              date: nil,
              rights: nil,
              is_enabled: nil

    @type t :: %BusinessConnection{
            id: binary,
            user: User.t(),
            user_chat_id: integer,
            date: integer,
            rights: BusinessBotRights.t(),
            is_enabled: boolean
          }
  end

  defmodule BusinessMessagesDeleted do
    defstruct business_connection_id: nil, chat: nil, message_ids: []

    @type t :: %BusinessMessagesDeleted{
            business_connection_id: binary,
            chat: Chat.t(),
            message_ids: [integer]
          }
  end

  defmodule SentGuestMessage do
    defstruct inline_message_id: nil

    @type t :: %SentGuestMessage{
            inline_message_id: binary
          }
  end

  defmodule ManagedBotCreated do
    defstruct bot: nil

    @type t :: %ManagedBotCreated{
            bot: User.t()
          }
  end

  defmodule ManagedBotUpdated do
    defstruct user: nil, bot: nil

    @type t :: %ManagedBotUpdated{
            user: User.t(),
            bot: User.t()
          }
  end

  defmodule BotAccessSettings do
    defstruct is_access_restricted: nil, added_users: []

    @type t :: %BotAccessSettings{
            is_access_restricted: boolean,
            added_users: [User.t()]
          }
  end

  defmodule ChatBoostSource do
    defstruct source: nil

    @type t ::
            %ChatBoostSource{source: binary}
            | ChatBoostSourcePremium.t()
            | ChatBoostSourceGiftCode.t()
            | ChatBoostSourceGiveaway.t()
  end

  defmodule ChatBoostSourcePremium do
    defstruct source: nil, user: nil

    @type t :: %ChatBoostSourcePremium{
            source: binary,
            user: User.t()
          }
  end

  defmodule ChatBoostSourceGiftCode do
    defstruct source: nil, user: nil

    @type t :: %ChatBoostSourceGiftCode{
            source: binary,
            user: User.t()
          }
  end

  defmodule ChatBoostSourceGiveaway do
    defstruct source: nil,
              giveaway_message_id: nil,
              user: nil,
              prize_star_count: nil,
              is_unclaimed: nil

    @type t :: %ChatBoostSourceGiveaway{
            source: binary,
            giveaway_message_id: integer,
            user: User.t(),
            prize_star_count: integer,
            is_unclaimed: boolean
          }
  end

  defmodule ChatBoost do
    defstruct boost_id: nil, add_date: nil, expiration_date: nil, source: nil

    @type t :: %ChatBoost{
            boost_id: binary,
            add_date: integer,
            expiration_date: integer,
            source: ChatBoostSource.t()
          }
  end

  defmodule ChatBoostUpdated do
    defstruct chat: nil, boost: nil

    @type t :: %ChatBoostUpdated{
            chat: Chat.t(),
            boost: ChatBoost.t()
          }
  end

  defmodule ChatBoostRemoved do
    defstruct chat: nil, boost_id: nil, remove_date: nil, source: nil

    @type t :: %ChatBoostRemoved{
            chat: Chat.t(),
            boost_id: binary,
            remove_date: integer,
            source: ChatBoostSource.t()
          }
  end

  defmodule UserChatBoosts do
    defstruct boosts: []

    @type t :: %UserChatBoosts{
            boosts: [ChatBoost.t()]
          }
  end

  defmodule ChatBoostAdded do
    defstruct boost_count: nil

    @type t :: %ChatBoostAdded{
            boost_count: integer
          }
  end

  defmodule MessageEntity do
    defstruct type: nil,
              offset: nil,
              length: nil,
              url: nil,
              user: nil,
              language: nil,
              custom_emoji_id: nil,
              unix_time: nil,
              date_time_format: nil

    @type t :: %MessageEntity{
            type: binary,
            offset: integer,
            length: integer,
            url: binary,
            user: User.t(),
            language: binary,
            custom_emoji_id: binary,
            unix_time: integer,
            date_time_format: binary
          }
  end

  defmodule ReactionType do
    defstruct type: nil, emoji: nil, custom_emoji_id: nil

    @type t :: %ReactionType{
            type: binary,
            emoji: binary,
            custom_emoji_id: binary
          }
  end

  defmodule ReactionCount do
    defstruct type: nil, total_count: nil

    @type t :: %ReactionCount{
            type: ReactionType.t(),
            total_count: integer
          }
  end

  defmodule MessageReactionUpdated do
    defstruct chat: nil,
              message_id: nil,
              user: nil,
              actor_chat: nil,
              date: nil,
              old_reaction: [],
              new_reaction: []

    @type t :: %MessageReactionUpdated{
            chat: Chat.t(),
            message_id: integer,
            user: User.t(),
            actor_chat: Chat.t(),
            date: integer,
            old_reaction: [ReactionType.t()],
            new_reaction: [ReactionType.t()]
          }
  end

  defmodule MessageReactionCountUpdated do
    defstruct chat: nil, message_id: nil, date: nil, reactions: []

    @type t :: %MessageReactionCountUpdated{
            chat: Chat.t(),
            message_id: integer,
            date: integer,
            reactions: [ReactionCount.t()]
          }
  end

  defmodule PollMedia do
    defstruct animation: nil,
              audio: nil,
              document: nil,
              live_photo: nil,
              location: nil,
              photo: [],
              sticker: nil,
              venue: nil,
              video: nil

    @type t :: %PollMedia{
            animation: any,
            audio: Audio.t(),
            document: Document.t(),
            live_photo: any,
            location: Location.t(),
            photo: [PhotoSize.t()],
            sticker: Sticker.t(),
            venue: Venue.t(),
            video: Video.t()
          }
  end

  defmodule PollOption do
    defstruct persistent_id: nil,
              text: nil,
              text_entities: nil,
              media: nil,
              voter_count: nil,
              added_by_user: nil,
              added_by_chat: nil,
              addition_date: nil

    @type t :: %PollOption{
            persistent_id: binary,
            text: binary,
            text_entities: [MessageEntity.t()],
            media: PollMedia.t(),
            voter_count: integer,
            added_by_user: User.t(),
            added_by_chat: Chat.t(),
            addition_date: integer
          }
  end

  defmodule PollAnswer do
    defstruct poll_id: nil,
              voter_chat: nil,
              user: nil,
              option_ids: [],
              option_persistent_ids: []

    @type t :: %PollAnswer{
            poll_id: binary,
            voter_chat: Chat.t(),
            user: User.t(),
            option_ids: [integer],
            option_persistent_ids: [binary]
          }
  end

  defmodule Poll do
    defstruct id: nil,
              question: nil,
              question_entities: nil,
              options: [],
              total_voter_count: nil,
              is_closed: nil,
              is_anonymous: nil,
              type: nil,
              allows_multiple_answers: nil,
              allows_revoting: nil,
              members_only: nil,
              country_codes: nil,
              correct_option_ids: nil,
              explanation: nil,
              explanation_entities: nil,
              explanation_media: nil,
              open_period: nil,
              close_date: nil,
              description: nil,
              description_entities: nil,
              media: nil

    @type t :: %Poll{
            id: binary,
            question: binary,
            question_entities: [MessageEntity.t()],
            options: [PollOption.t()],
            total_voter_count: integer,
            is_closed: boolean,
            is_anonymous: boolean,
            type: binary,
            allows_multiple_answers: boolean,
            allows_revoting: boolean,
            members_only: boolean,
            country_codes: [binary],
            correct_option_ids: [integer],
            explanation: binary,
            explanation_entities: [MessageEntity.t()],
            explanation_media: PollMedia.t(),
            open_period: integer,
            close_date: integer,
            description: binary,
            description_entities: [MessageEntity.t()],
            media: PollMedia.t()
          }
  end

  defmodule PollOptionAdded do
    defstruct poll_message: nil,
              option_persistent_id: nil,
              option_text: nil,
              option_text_entities: nil

    @type t :: %PollOptionAdded{
            poll_message: Message.t(),
            option_persistent_id: binary,
            option_text: binary,
            option_text_entities: [MessageEntity.t()]
          }
  end

  defmodule PollOptionDeleted do
    defstruct poll_message: nil,
              option_persistent_id: nil,
              option_text: nil,
              option_text_entities: nil

    @type t :: %PollOptionDeleted{
            poll_message: Message.t(),
            option_persistent_id: binary,
            option_text: binary,
            option_text_entities: [MessageEntity.t()]
          }
  end

  defmodule InlineQuery do
    defstruct id: nil, from: nil, location: nil, query: nil, offset: nil

    @type t :: %InlineQuery{
            id: binary,
            from: User.t(),
            location: Location.t(),
            query: binary,
            offset: integer
          }
  end

  defmodule ChosenInlineResult do
    defstruct result_id: nil, from: nil, location: nil, inline_message_id: nil, query: nil

    @type t :: %ChosenInlineResult{
            result_id: binary,
            from: User.t(),
            location: Location.t(),
            inline_message_id: binary,
            query: binary
          }
  end

  defmodule Update do
    defstruct update_id: nil,
              message: nil,
              edited_message: nil,
              channel_post: nil,
              edited_channel_post: nil,
              business_connection: nil,
              business_message: nil,
              edited_business_message: nil,
              deleted_business_messages: nil,
              guest_message: nil,
              message_reaction: nil,
              message_reaction_count: nil,
              inline_query: nil,
              chosen_inline_result: nil,
              callback_query: nil,
              shipping_query: nil,
              pre_checkout_query: nil,
              purchased_paid_media: nil,
              poll: nil,
              poll_answer: nil,
              my_chat_member: nil,
              chat_member: nil,
              chat_join_request: nil,
              chat_boost: nil,
              removed_chat_boost: nil,
              managed_bot: nil

    @type t :: %Update{
            update_id: integer,
            message: Message.t(),
            edited_message: Message.t(),
            channel_post: Message.t(),
            edited_channel_post: Message.t(),
            business_connection: BusinessConnection.t(),
            business_message: Message.t(),
            edited_business_message: Message.t(),
            deleted_business_messages: BusinessMessagesDeleted.t(),
            guest_message: Message.t(),
            message_reaction: MessageReactionUpdated.t(),
            message_reaction_count: MessageReactionCountUpdated.t(),
            inline_query: InlineQuery.t(),
            chosen_inline_result: ChosenInlineResult.t(),
            callback_query: CallbackQuery.t(),
            shipping_query: any,
            pre_checkout_query: any,
            purchased_paid_media: PaidMediaPurchased.t(),
            poll: Poll.t(),
            poll_answer: PollAnswer.t(),
            my_chat_member: any,
            chat_member: any,
            chat_join_request: any,
            chat_boost: ChatBoostUpdated.t(),
            removed_chat_boost: ChatBoostRemoved.t(),
            managed_bot: ManagedBotUpdated.t()
          }
  end

  defmodule UserProfilePhotos do
    defstruct total_count: nil, photos: []
    @type t :: %UserProfilePhotos{total_count: integer, photos: [[PhotoSize.t()]]}
  end

  defmodule File do
    defstruct file_id: nil, file_size: nil, file_path: nil
    @type t :: %File{file_id: binary, file_size: integer, file_path: binary}
  end

  defmodule ReplyKeyboardMarkup do
    @derive Jason.Encoder
    defstruct keyboard: [], resize_keyboard: false, one_time_keyboard: false, selective: false

    @type t :: %ReplyKeyboardMarkup{
            keyboard: [[KeyboardButton.t()]],
            resize_keyboard: atom,
            one_time_keyboard: atom,
            selective: atom
          }
  end

  defmodule KeyboardButton do
    @derive Jason.Encoder
    defstruct text: nil, request_contact: false, request_location: false
    @type t :: %KeyboardButton{text: binary, request_contact: atom, request_location: atom}
  end

  defmodule ReplyKeyboardRemove do
    @derive Jason.Encoder
    defstruct remove_keyboard: true, selective: false
    @type t :: %ReplyKeyboardRemove{remove_keyboard: true, selective: atom}
  end

  defmodule InlineKeyboardMarkup do
    @derive Jason.Encoder
    defstruct inline_keyboard: []
    @type t :: %InlineKeyboardMarkup{inline_keyboard: [[InlineKeyboardButton.t()]]}
  end

  defmodule InlineKeyboardButton do
    defstruct text: nil,
              url: nil,
              callback_data: nil,
              switch_inline_query: nil,
              switch_inline_query_current_chat: nil

    @type t :: %InlineKeyboardButton{
            text: binary,
            url: binary,
            callback_data: binary,
            switch_inline_query: binary,
            switch_inline_query_current_chat: binary
          }
  end

  defmodule CallbackQuery do
    defstruct id: nil, from: nil, message: nil, inline_message_id: nil, data: nil

    @type t :: %CallbackQuery{
            id: binary,
            from: User.t(),
            message: Message.t(),
            inline_message_id: binary,
            data: binary
          }
  end

  defmodule ForceReply do
    @derive Jason.Encoder
    defstruct force_reply: true, selective: false
    @type t :: %ForceReply{force_reply: true, selective: atom}
  end

  defmodule ChatMember do
    defstruct user: nil, status: nil
    @type t :: %ChatMember{user: User.t(), status: binary}
  end

  defmodule WebhookInfo do
    defstruct url: nil,
              has_custom_certificate: nil,
              pending_update_count: nil,
              last_error_date: nil,
              last_error_message: nil,
              max_connections: nil,
              allowed_updates: []

    @type t :: %WebhookInfo{
            url: binary,
            has_custom_certificate: boolean,
            pending_update_count: non_neg_integer,
            last_error_date: non_neg_integer,
            last_error_message: binary,
            max_connections: non_neg_integer,
            allowed_updates: [binary]
          }
  end

  defmodule Error do
    defexception reason: nil
    @type t :: %Error{reason: any}

    def message(%Error{reason: reason}), do: inspect(reason)
  end
end
