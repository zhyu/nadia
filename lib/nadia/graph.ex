defmodule Nadia.Graph do
  @moduledoc """
  Provides access to Telegra.ph API.

  ## Reference
  http://telegra.ph/api
  """

  alias Nadia.Graph.Model.{Account, Error}

  import Nadia.Graph.API

  @doc """
  Use this method to create a new Telegraph account. Most users only need one account, but this can be useful for channel administrators who would like to keep individual author names and profile links for each of their channels. On success, returns an Account object with the regular fields and an additional access_token field.

  Args:
  * `short_name` - account name, helps users with several accounts remember which they are currently using. Displayed to the user above the "Edit/Publish" button on Telegra.ph, other users don't see this name. 1-32 characters
  * `author_name` - default author name used when creating new articles. 0-128 characters
  * `options` - orddict of options

  Options:
  * `:author_url` - default profile link, opened when users click on the author's name below the title. Can be any link, not necessarily to a Telegram profile or channel. 0-512 characters
  """
  @spec create_account(binary, binary, [{atom, any}]) :: {:ok, Account.t()} | {:error, Error.t()}
  def create_account(short_name, author_name, options \\ []) do
    request("createAccount", [short_name: short_name, author_name: author_name] ++ options)
  end

  @doc """
  Use this method to update information about a Telegraph account. Pass only the parameters that you want to edit. On success, returns an Account object with the default fields.

  * `access_token` - access token of the Telegraph account
  * `short_name` - new account name. 1-32 characters
  * `author_name` - new default author name used when creating new articles. 0-128 characters
  * `options` - orddict of options

  Options:
  * `:author_url` - new default profile link, opened when users click on the author's name below the title. Can be any link, not necessarily to a Telegram profile or channel. 0-512 characters
  """
  @spec edit_account_info(binary, binary, binary, [{atom, any}]) ::
          {:ok, Account.t()} | {:error, Error.t()}
  def edit_account_info(access_token, short_name, author_name, options \\ []) do
    request(
      "editAccountInfo",
      [access_token: access_token, short_name: short_name, author_name: author_name] ++ options
    )
  end

  @doc """
  Use this method to get information about a Telegraph account. Returns an Account object on success.

  * `access_token` - access token of the Telegraph account
  * `fields` - list of account fields to return. Available fields: short_name, author_name, author_url, auth_url, page_count
  """
  @spec get_account_info(binary, [binary]) :: {:ok, Account.t()} | {:error, Error.t()}
  def get_account_info(access_token, fields \\ ["short_name", "author_name", "author_url"]) do
    request("getAccountInfo", access_token: access_token, fields: fields)
  end

  @doc """
  Use this method to revoke access_token and generate a new one, for example, if the user would like to reset all connected sessions, or you have reasons to believe the token was compromised. On success, returns an Account object with new access_token and auth_url fields.

  * `access_token` - access token of the Telegraph account
  """
  @spec revoke_access_token(binary) :: {:ok, Account.t()} | {:error, Error.t()}
  def revoke_access_token(access_token) do
    request("revokeAccessToken", access_token: access_token)
  end

  @doc """
  Use this method to get a list of pages belonging to a Telegraph account. Returns a PageList object, sorted by most recently created pages first.

  * `access_token` - access token of the Telegraph account
  * `offset` - sequential number of the first page to be returned
  * `limit` - limits the number of pages to be retrieved. 0-200
  """
  @spec get_page_list(binary, integer, integer) :: {:ok, [[PageList.t()]]} | {:error, Error.t()}
  def get_page_list(access_token, offset \\ 0, limit \\ 50) do
    request("getPageList", access_token: access_token, offset: offset, limit: limit)
  end

  @doc """
  Use this method to create a new Telegraph page. On success, returns a Page object.

  Args:
  * `access_token` - (String) Access token of the Telegraph account.
  * `title` - (String, 1-256 characters) Page title.
  * `content` - (Array of Node, up to 64 KB)` Content of the page.
  * `options` - orddict of options

  Options:
  * `:author_name` - (String, 0-128 characters) Author name, displayed below the article's title.
  * `:author_url` - (String, 0-512 characters) Profile link, opened when users click on the author's name below the title. Can be any link, not necessarily to a Telegram profile or channel.
  * `:return_content` - (Boolean, default = false) If true, a content field will be returned in the Page object (see: Content format).
  """
  @spec create_page(binary, binary, binary, [{atom, any}]) ::
          {:ok, Page.t()} | {:error, Error.t()}
  def create_page(access_token, title, content, options \\ []) do
    request("createPage", [access_token: access_token, title: title, content: content] ++ options)
  end

  @doc """
  Use this method to edit an existing Telegraph page. On success, returns a Page object.

  * `access_token` - (String) Access token of the Telegraph account.
  * `path` - (String) Path to the page.
  * `title` - (String, 1-256 characters) Page title.
  * `content` - (Array of Node, up to 64 KB) Content of the page.
  * `options` - orddict of options

  Options:
  * `:author_name` - (String, 0-128 characters) Author name, displayed below the article's title.
  * `:author_url` - (String, 0-512 characters) Profile link, opened when users click on the author's * `:name below` - the title. Can be any link, not necessarily to a Telegram profile or channel.
  * `:return_content` - (Boolean, default = false) If true, a content field will be returned in the Page object.
  """
  @spec edit_page(binary, binary, binary, binary, [{atom, any}]) ::
          {:ok, Page.t()} | {:error, Error.t()}
  def edit_page(access_token, path, title, content, options \\ []) do
    request(
      "editPage/" <> path,
      [access_token: access_token, title: title, content: content] ++ options
    )
  end

  @doc """
  Use this method to get a Telegraph page. Returns a Page object on success.

  * `path` path to the Telegraph page (in the format Title-12-31, i.e. everything that comes after http://telegra.ph/)
  * `return_content` - if true, content field will be returned in Page object
  """
  @spec get_page(binary, [atom]) :: {:ok, Page.t()} | {:error, Error.t()}
  def get_page(path, return_content \\ true) do
    request("getPage/" <> path, return_content: return_content)
  end

  @doc """
  Use this method to get the number of views for a Telegraph article. Returns a PageViews object on success. By default, the total number of page views will be returned.

  * `path` - path to the Telegraph page (in the format Title-12-31, where 12 is the month and 31 the day the article was first published)
  * `filter_fields` - orddict of fields

  Filter fields:
  * `:year` - if passed, the number of page views for the requested year will be returned.
  * `:month` - if passed, the number of page views for the requested month will be returned
  * `:day` - if passed, the number of page views for the requested day will be returned.
  * `:hour` - if passed, the number of page views for the requested hour will be returned.
  """
  @spec get_views(binary, [{atom, any}]) :: {:ok, PageViews.t()} | {:error, Error.t()}
  def get_views(path, filter_fields) do
    request("getViews/" <> path, filter_fields)
  end
end
