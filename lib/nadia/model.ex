defmodule Nadia.Model do
  @moduledoc """
  Types used in Telegram Bot API.

  ## Reference
  https://core.telegram.org/bots/api#available-types
  """

  defmodule User do
    defstruct id: nil, first_name: nil, last_name: nil, username: nil
    @type t :: %User{id: integer, first_name: binary, last_name: binary, username: binary}
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
    defstruct file_id: nil, width: nil, height: nil, file_size: nil
    @type t :: %PhotoSize{file_id: binary, width: integer, height: integer, file_size: integer}
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
    defstruct file_id: nil, width: nil, height: nil, thumb: nil, emoji: nil, file_size: nil

    @type t :: %Sticker{
            file_id: binary,
            width: integer,
            height: integer,
            thumb: PhotoSize.t(),
            emoji: binary,
            file_size: integer
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
              from: nil,
              date: nil,
              chat: nil,
              forward_from: nil,
              forward_from_chat: nil,
              forward_date: nil,
              reply_to_message: nil,
              edit_date: nil,
              text: nil,
              entities: nil,
              audio: nil,
              document: nil,
              photo: [],
              sticker: nil,
              video: nil,
              voice: nil,
              caption: nil,
              contact: nil,
              location: nil,
              venue: nil,
              new_chat_member: nil,
              left_chat_member: nil,
              new_chat_title: nil,
              new_chat_photo: [],
              delete_chat_photo: nil,
              group_chat_created: nil,
              supergroup_chat_created: nil,
              channel_chat_created: nil,
              migrate_to_chat_id: nil,
              migrate_from_chat_id: nil,
              pinned_message: nil

    @type t :: %Message{
            message_id: integer,
            from: User.t(),
            date: integer,
            chat: Chat.t(),
            forward_from: User.t(),
            forward_from_chat: Chat.t(),
            forward_date: integer,
            reply_to_message: Message.t(),
            edit_date: integer,
            text: binary,
            entities: MessageEntity.t(),
            audio: Audio.t(),
            document: Document.t(),
            photo: [PhotoSize.t()],
            sticker: any,
            video: any,
            voice: any,
            caption: binary,
            contact: any,
            location: any,
            venue: any,
            new_chat_member: User.t(),
            left_chat_member: User.t(),
            new_chat_title: binary,
            new_chat_photo: [PhotoSize.t()],
            delete_chat_photo: atom,
            group_chat_created: atom,
            supergroup_chat_created: atom,
            channel_chat_created: atom,
            migrate_to_chat_id: integer,
            migrate_from_chat_id: integer,
            pinned_message: Message.t()
          }
  end

  defmodule MessageEntity do
    defstruct type: nil, offset: nil, length: nil, url: nil, user: nil

    @type t :: %MessageEntity{
            type: binary,
            offset: integer,
            length: integer,
            url: binary,
            user: User.t()
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
              inline_query: nil,
              chosen_inline_result: nil,
              callback_query: nil

    @type t :: %Update{
            update_id: integer,
            message: Message.t(),
            edited_message: Message.t(),
            channel_post: Message.t(),
            inline_query: InlineQuery.t(),
            chosen_inline_result: ChosenInlineResult.t(),
            callback_query: CallbackQuery.t()
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
    defstruct keyboard: [], resize_keyboard: false, one_time_keyboard: false, selective: false

    @type t :: %ReplyKeyboardMarkup{
            keyboard: [[KeyboardButton.t()]],
            resize_keyboard: atom,
            one_time_keyboard: atom,
            selective: atom
          }
  end

  defmodule KeyboardButton do
    defstruct text: nil, request_contact: false, request_location: false
    @type t :: %KeyboardButton{text: binary, request_contact: atom, request_location: atom}
  end

  defmodule ReplyKeyboardHide do
    defstruct hide_keyboard: true, selective: false
    @type t :: %ReplyKeyboardHide{hide_keyboard: true, selective: atom}
  end

  defmodule InlineKeyboardMarkup do
    defstruct inline_keyboard: []
    @type t :: %InlineKeyboardMarkup{inline_keyboard: [[InlineKeyboardButton.t()]]}
  end

  defmodule InlineKeyboardButton do
    defstruct text: nil, url: nil, callback_data: nil, switch_inline_query: nil

    @type t :: %InlineKeyboardButton{
            text: binary,
            url: binary,
            callback_data: binary,
            switch_inline_query: binary
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
    defstruct force_reply: true, selective: false
    @type t :: %ForceReply{force_reply: true, selective: atom}
  end

  defmodule ChatMember do
    defstruct user: nil, status: nil
    @type t :: %ChatMember{user: User.t(), status: binary}
  end

  defmodule Error do
    defexception reason: nil
    @type t :: %Error{reason: any}

    def message(%Error{reason: reason}), do: inspect(reason)
  end
end
