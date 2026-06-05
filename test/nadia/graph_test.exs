defmodule Nadia.GraphTest do
  use Nadia.HTTPCase

  doctest Nadia.Graph

  alias Nadia.Graph.Model.{Account, Error, Page, PageList, PageViews}
  alias Nadia.HTTPResponse

  defp stub_graph_result(result) do
    stub_http_response(
      {:ok, %HTTPResponse{status_code: 200, body: Jason.encode!(%{ok: true, result: result})}}
    )
  end

  defp stub_graph_error(reason) do
    stub_http_response(
      {:ok, %HTTPResponse{status_code: 400, body: Jason.encode!(%{ok: false, error: reason})}}
    )
  end

  defp assert_graph_request(api_method, expected) do
    defaults = [
      method: :post,
      url: graph_url(api_method),
      headers: []
    ]

    assert_http_request(Keyword.merge(defaults, expected))
  end

  test "create_account builds a request and parses an account" do
    stub_graph_result(%{
      short_name: "some_short_name",
      author_name: "some_author_name",
      access_token: "access-token"
    })

    assert {:ok,
            %Account{
              short_name: "some_short_name",
              author_name: "some_author_name",
              access_token: "access-token"
            }} =
             Nadia.Graph.create_account(
               "some_short_name",
               "some_author_name",
               author_url: "https://example.test"
             )

    assert_graph_request("createAccount",
      body:
        {:form,
         [
           {"short_name", "some_short_name"},
           {"author_name", "some_author_name"},
           {"author_url", "https://example.test"}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "account management wrappers build requests and parse accounts" do
    access_token = "b968da509bb76866c35425099bc0989a5ec3b32997d55286c657e6994bbb"

    stub_graph_result(%{short_name: "some_short_name", author_name: "some_author_name"})

    assert {:ok, %Account{short_name: "some_short_name"}} =
             Nadia.Graph.edit_account_info(
               access_token,
               "some_short_name",
               "some_author_name"
             )

    assert_graph_request("editAccountInfo",
      body:
        {:form,
         [
           {"access_token", access_token},
           {"short_name", "some_short_name"},
           {"author_name", "some_author_name"}
         ]},
      options: [recv_timeout: 5000]
    )

    stub_graph_result(%{short_name: "some_short_name", page_count: 42})

    assert {:ok, %Account{short_name: "some_short_name", page_count: 42}} =
             Nadia.Graph.get_account_info(access_token, ["short_name", "page_count"])

    assert_graph_request("getAccountInfo",
      body:
        {:form,
         [
           {"access_token", access_token},
           {"fields", "short_namepage_count"}
         ]},
      options: [recv_timeout: 5000]
    )

    stub_graph_result(%{short_name: "some_short_name", access_token: "new-access-token"})

    assert {:ok, %Account{short_name: "some_short_name", access_token: "new-access-token"}} =
             Nadia.Graph.revoke_access_token(access_token)

    assert_graph_request("revokeAccessToken",
      body: {:form, [{"access_token", access_token}]},
      options: [recv_timeout: 5000]
    )
  end

  test "page wrappers build requests and parse page models" do
    access_token = "b968da509bb76866c35425099bc0989a5ec3b32997d55286c657e6994bbb"
    content = ~s([{"tag":"p","children":["Hello, world!"]}])

    stub_graph_result(%{
      total_count: 1058,
      pages: [%{path: "Sample-Page-01-13-6", title: "Sample Page"}]
    })

    assert {:ok, %PageList{total_count: 1058, pages: [%Page{path: "Sample-Page-01-13-6"}]}} =
             Nadia.Graph.get_page_list(access_token, 0, 3)

    assert_graph_request("getPageList",
      body:
        {:form,
         [
           {"access_token", access_token},
           {"offset", "0"},
           {"limit", "3"}
         ]},
      options: [recv_timeout: 5000]
    )

    stub_graph_result(%{path: "Sample-Page", title: "Sample Page"})

    assert {:ok, %Page{path: "Sample-Page", title: "Sample Page"}} =
             Nadia.Graph.create_page(access_token, "Sample Page", content)

    assert_graph_request("createPage",
      body:
        {:form,
         [
           {"access_token", access_token},
           {"title", "Sample Page"},
           {"content", content}
         ]},
      options: [recv_timeout: 5000]
    )

    stub_graph_result(%{path: "Sample-Page-12-15", title: "Sample Page", content: []})

    assert {:ok, %Page{title: "Sample Page", content: []}} =
             Nadia.Graph.get_page("Sample-Page-12-15")

    assert_graph_request("getPage/Sample-Page-12-15",
      body: {:form, [{"return_content", "true"}]},
      options: [recv_timeout: 5000]
    )

    stub_graph_result(%{path: "Sample-Page-12-15", title: "Sample Page2"})

    assert {:ok, %Page{title: "Sample Page2"}} =
             Nadia.Graph.edit_page(access_token, "Sample-Page-12-15", "Some Page2", content)

    assert_graph_request("editPage/Sample-Page-12-15",
      body:
        {:form,
         [
           {"access_token", access_token},
           {"title", "Some Page2"},
           {"content", content}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "request ignores unknown Telegraph response fields without creating atoms" do
    unknown_key = "telegraph_unknown_#{System.unique_integer([:positive])}"
    refute existing_atom?(unknown_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body:
           Jason.encode!(%{
             "ok" => true,
             "result" => %{
               "path" => "Sample-Page",
               "title" => "Sample Page",
               unknown_key => "ignored"
             }
           })
       }}
    )

    assert {:ok, %Page{path: "Sample-Page", title: "Sample Page"}} =
             Nadia.Graph.get_page("Sample-Page")

    refute existing_atom?(unknown_key)
  end

  test "get_views builds a request and parses page views" do
    stub_graph_result(%{views: 40})

    assert {:ok, %PageViews{views: 40}} =
             Nadia.Graph.get_views("Sample-Page-12-15", year: 2012, month: 12)

    assert_graph_request("getViews/Sample-Page-12-15",
      body: {:form, [{"year", "2012"}, {"month", "12"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "request uses configured graph base URL and timeout" do
    Application.put_env(:nadia, :graph_base_url, "https://graph.example.test")
    Application.put_env(:nadia, :recv_timeout, 12)

    stub_graph_result(%{views: 40})

    assert {:ok, %PageViews{views: 40}} =
             Nadia.Graph.get_views("Sample-Page-12-15", year: 2012, timeout: 2)

    assert_http_request(
      method: :post,
      url: "https://graph.example.test/getViews/Sample-Page-12-15",
      body: {:form, [{"year", "2012"}, {"timeout", "2"}]},
      headers: [],
      options: [recv_timeout: 14_000]
    )
  end

  test "request normalizes Telegraph errors" do
    stub_graph_error("ACCESS_TOKEN_INVALID")

    assert {:error, %Error{reason: "ACCESS_TOKEN_INVALID"}} =
             Nadia.Graph.get_account_info("bad-token")
  end

  test "request normalizes transport errors" do
    stub_transport_error(:timeout)

    assert {:error, %Error{reason: :timeout}} = Nadia.Graph.get_page("Sample-Page")
  end

  test "request normalizes malformed JSON responses" do
    stub_http_response({:ok, %HTTPResponse{status_code: 200, body: "not json"}})

    assert {:error, %Error{reason: %Jason.DecodeError{}}} = Nadia.Graph.get_page("Sample-Page")
  end

  defp existing_atom?(name) do
    _ = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end
end
