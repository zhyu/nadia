# Use The Telegraph API

`Nadia.Graph` wraps the [Telegraph API](https://telegra.ph/api), which is
separate from the Telegram Bot API. It can create and manage lightweight
Telegraph pages without a bot token.

## Create An Account

Create an account once and store its access token as a secret:

```elixir
{:ok, account} =
  Nadia.Graph.create_account(
    "my_app",
    "My App",
    author_url: "https://example.com"
  )

account.access_token
```

The returned token controls the account and its pages. Do not put account
creation in a normal application startup path, and do not log or commit the
token.

## Create A Page

Telegraph content is a JSON-encoded array of nodes:

```elixir
content =
  Jason.encode!([
    %{tag: "p", children: ["Hello from Nadia."]},
    %{
      tag: "p",
      children: [
        %{tag: "a", attrs: %{href: "https://hexdocs.pm/nadia"}, children: ["Nadia docs"]}
      ]
    }
  ])

{:ok, page} =
  Nadia.Graph.create_page(
    System.fetch_env!("TELEGRAPH_ACCESS_TOKEN"),
    "Nadia Example",
    content,
    return_content: true
  )

page.url
```

`create_page/4` currently accepts the encoded content string expected by the
Telegraph form API. Build nodes as maps and lists, then encode them with Jason
rather than assembling JSON by hand.

## Read Or Edit A Page

The page path is the part after `https://telegra.ph/`:

```elixir
{:ok, page} = Nadia.Graph.get_page("Nadia-Example-06-20", true)

{:ok, edited_page} =
  Nadia.Graph.edit_page(
    System.fetch_env!("TELEGRAPH_ACCESS_TOKEN"),
    page.path,
    "Updated Nadia Example",
    content
  )
```

Use `get_page_list/3` to list pages for an account and `get_views/2` to read
view counts. Telegraph errors return `{:error, %Nadia.Graph.Model.Error{}}`, so
handle them independently from `Nadia.Model.Error` returned by Bot API calls.
