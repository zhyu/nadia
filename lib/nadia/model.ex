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

  defmodule Chat do
    defstruct id: nil, type: nil, title: nil, username: nil, first_name: nil, last_name: nil
    @type t :: %Chat{id: integer, type: binary, title: binary, username: binary, first_name: binary, last_name: binary}
  end

  defmodule PhotoSize do
    defstruct file_id: nil, width: nil, height: nil, file_size: nil
    @type t :: %PhotoSize{file_id: binary, width: integer, height: integer, file_size: integer}
  end

  defmodule Audio do
    defstruct file_id: nil, duration: nil, performer: nil, title: nil, mime_type: nil, file_size: nil
    @type t :: %Audio{file_id: binary, duration: integer, performer: binary, title: binary,
                      mime_type: binary, file_size: integer}
  end

  defmodule Document do
    defstruct file_id: nil, thumb: nil, file_name: nil, mime_type: nil, file_size: nil
    @type t :: %Document{file_id: binary, thumb: PhotoSize.t, file_name: binary, mime_type: binary, file_size: integer}
  end

  defmodule Sticker do
    defstruct file_id: nil, width: nil, height: nil, thumb: nil, file_size: nil
    @type t :: %Sticker{file_id: binary, width: integer, height: integer, thumb: PhotoSize.t, file_size: integer}
  end

  defmodule Video do
    defstruct file_id: nil, width: nil, height: nil, duration: nil, thumb: nil, mime_type: nil, file_size: nil
    @type t :: %Video{file_id: binary, width: integer, height: integer, duration: integer, thumb: PhotoSize.t,
                      mime_type: binary, file_size: integer}
  end

  defmodule Voice do
    defstruct file_id: nil, duration: nil, mime_type: nil, file_size: nil
    @type t :: %Voice{file_id: binary, duration: integer, mime_type: binary, file_size: integer}
  end

  defmodule Contact do
    defstruct phone_number: nil, first_name: nil, last_name: nil, user_id: nil
    @type t :: %Contact{phone_number: binary, first_name: binary, last_name: binary, user_id: integer}
  end

  defmodule Location do
    defstruct latitude: nil, longitude: nil
    @type t :: %Location{latitude: float, longitude: float}
  end

  defmodule Message do
    defstruct message_id: nil, from: nil, date: nil, chat: nil, forward_from: nil,
    forward_date: nil, reply_to_message: nil, text: nil, audio: nil, document: nil,
    photo: [], sticker: nil, video: nil, voice: nil, caption: nil, contact: nil,
    location: nil, new_chat_participant: nil, left_chat_participant: nil,
    new_chat_title: nil, new_chat_photo: [], delete_chat_photo: nil, group_chat_created: nil

    @type t :: %Message{message_id: integer, from: User.t, date: integer, chat: User.t | GroupChat.t,
                        forward_from: User.t, forward_date: integer, reply_to_message: Message.t,
                        text: binary, audio: Audio.t, document: Document.t, photo: [PhotoSize.t], sticker: any,
                        video: any, voice: any, caption: binary, contact: any, location: any,
                        new_chat_participant: User.t, left_chat_participant: User.t, new_chat_title: binary,
                        new_chat_photo: [PhotoSize.t], delete_chat_photo: atom, group_chat_created: atom}
  end

  defmodule InlineQuery do
    defstruct id: nil, from: nil, query: nil, offset: nil
    @type t :: %InlineQuery{id: binary, from: User.t, query: binary, offset: integer}
  end

  defmodule Update do
    defstruct update_id: nil, message: nil, inline_query: nil
    @type t :: %Update{update_id: integer, message: Message.t, inline_query: InlineQuery.t}
  end

  defmodule UserProfilePhotos do
    defstruct total_count: nil, photos: []
    @type t :: %UserProfilePhotos{total_count: integer, photos: [[PhotoSize.t]]}
  end

  defmodule File do
    defstruct file_id: nil, file_size: nil, file_path: nil
    @type t :: %File{file_id: binary, file_size: integer, file_path: binary}
  end

  defmodule ReplyKeyboardMarkup do
    defstruct keyboard: [], resize_keyboard: false, one_time_keyboard: false, selective: false
    @type t :: %ReplyKeyboardMarkup{keyboard: [[binary]], resize_keyboard: atom, one_time_keyboard: atom, selective: atom}
  end

  defmodule ReplyKeyboardHide do
    defstruct hide_keyboard: true, selective: false
    @type t :: %ReplyKeyboardHide{hide_keyboard: true, selective: atom}
  end

  defmodule ForceReply do
    defstruct force_reply: true, selective: false
    @type t :: %ForceReply{force_reply: true, selective: atom}
  end

  defmodule Error do
    defexception reason: nil
    @type t :: %Error{reason: any}

    def message(%Error{reason: reason}), do: inspect(reason)
  end

end
