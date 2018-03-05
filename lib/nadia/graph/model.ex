defmodule Nadia.Graph.Model do
  @moduledoc """
  Types used in Telegra.ph API.

  ## Reference
  http://telegra.ph/api#Available-types
  """

  defmodule Account do
    defstruct short_name: nil,
              author_name: nil,
              author_url: nil,
              access_token: nil,
              auth_url: nil,
              page_count: nil

    @type t :: %Account{
            short_name: binary,
            author_name: binary,
            author_url: binary,
            access_token: binary,
            auth_url: binary,
            page_count: integer
          }
  end

  defmodule PageList do
    defstruct total_count: nil, pages: []
    @type t :: %PageList{total_count: integer, pages: [[Page.t()]]}
  end

  defmodule Page do
    defstruct path: nil,
              url: nil,
              title: nil,
              description: nil,
              author_name: nil,
              author_url: nil,
              image_url: nil,
              content: nil,
              views: nil,
              can_edit: nil

    @type t :: %Page{
            path: binary,
            url: binary,
            title: binary,
            description: binary,
            author_name: binary,
            author_url: binary,
            image_url: binary,
            content: NodeElement.t(),
            views: integer,
            can_edit: atom
          }
  end

  defmodule PageViews do
    defstruct views: nil
    @type t :: %PageViews{views: integer}
  end

  defmodule NodeElement do
    defstruct tag: nil, attrs: [], children: []
    @type t :: %NodeElement{tag: binary, attrs: [[any]], children: [[NodeElement.t()]]}
  end

  defmodule Error do
    defexception reason: nil
    @type t :: %Error{reason: any}

    def message(%Error{reason: reason}), do: inspect(reason)
  end
end
