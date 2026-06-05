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
              photo: nil

    @type t :: %Chat{
            id: integer,
            type: binary,
            title: binary,
            username: binary,
            first_name: binary,
            last_name: binary,
            photo: ChatPhoto.t()
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
              location: nil,
              venue: nil,
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
            paid_media: any,
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
            poll: any,
            location: any,
            venue: any,
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
            business_connection: any,
            business_message: Message.t(),
            edited_business_message: Message.t(),
            deleted_business_messages: any,
            guest_message: Message.t(),
            message_reaction: any,
            message_reaction_count: any,
            inline_query: InlineQuery.t(),
            chosen_inline_result: ChosenInlineResult.t(),
            callback_query: CallbackQuery.t(),
            shipping_query: any,
            pre_checkout_query: any,
            purchased_paid_media: any,
            poll: any,
            poll_answer: any,
            my_chat_member: any,
            chat_member: any,
            chat_join_request: any,
            chat_boost: any,
            removed_chat_boost: any,
            managed_bot: any
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
