defmodule Nadia.Model.InlineQueryResult do
  @type t :: Nadia.Model.InlineQueryResult.Photo.t |
             Nadia.Model.InlineQueryResult.Article.t |
             Nadia.Model.InlineQueryResult.Gif.t |
             Nadia.Model.InlineQueryResult.Mpeg4Gif.t |
             Nadia.Model.InlineQueryResult.Video.t

  defmodule Photo do
    defstruct type: "photo", id: nil, photo_url: nil, photo_width: nil,
      photo_height: nil, thumb_url: nil, title: nil, description: nil,
      caption: nil, message_text: nil, parse_mode: nil,
      disable_web_page_preview: nil
    @type t :: %Photo{type: binary, id: binary,
      photo_url: binary, photo_width: integer, photo_height: integer,
      thumb_url: binary, title: binary, description: binary, caption: binary,
      message_text: binary, parse_mode: binary,
      disable_web_page_preview: boolean}
  end

  defmodule Article do
    defstruct type: "article", id: nil, title: nil, description: nil,
      message_text: nil, parse_mode: nil, disable_web_page_preview: nil,
      url: nil, hide_url: nil, thumb_url: nil, thumb_width: nil,
      thumb_height: nil
    @type t :: %Article{type: binary, id: binary,
      title: binary, description: binary, message_text: binary,
      parse_mode: binary, disable_web_page_preview: boolean, url: binary,
      hide_url: boolean, thumb_url: binary, thumb_width: integer,
      thumb_height: integer}
  end

  defmodule Gif do
    defstruct type: "gif", id: nil, gif_url: nil, gif_width: nil,
      gif_height: nil, thumb_url: nil, title: nil, description: nil,
      caption: nil, message_text: nil, parse_mode: nil,
      disable_web_page_preview: nil
    @type t :: %Gif{type: binary, id: binary, gif_url: binary,
      gif_width: integer, gif_height: integer, thumb_url: binary, title: binary,
      description: binary, caption: binary, message_text: binary,
      parse_mode: binary, disable_web_page_preview: boolean}
  end

  defmodule Mpeg4Gif do
    defstruct type: "mpeg4_gif", id: nil, mpeg4_url: nil, mpeg4_width: nil,
      mpeg4_height: nil, thumb_url: nil, title: nil, description: nil,
      caption: nil, message_text: nil, parse_mode: nil,
      disable_web_page_preview: nil
    @type t :: %Mpeg4Gif{type: binary, id: binary,
      mpeg4_url: binary, mpeg4_width: integer, mpeg4_height: integer,
      thumb_url: binary, title: binary, description: binary, caption: binary,
      message_text: binary, parse_mode: binary,
      disable_web_page_preview: boolean}
  end

  defmodule Video do
    defstruct type: "video", id: nil, video_url: nil, video_width: nil,
      video_height: nil, thumb_url: nil, title: nil, description: nil,
      message_text: nil, parse_mode: nil, disable_web_page_preview: nil,
      mime_type: nil, video_duration: nil
    @type t :: %Video{type: binary, id: binary,
      video_url: binary, video_width: integer, video_height: integer,
      thumb_url: binary, title: binary, description: binary,
      message_text: binary, parse_mode: binary, video_duration: integer,
      disable_web_page_preview: boolean, mime_type: binary}
  end
end
