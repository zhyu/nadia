defmodule Nadia.GraphTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest Nadia.Graph

  setup_all do
    ExVCR.Config.filter_sensitive_data("bot[^/]+/", "bot<TOKEN>/")
    ExVCR.Config.filter_sensitive_data("id\":\\d+", "id\":666")
    ExVCR.Config.filter_sensitive_data("id=\\d+", "id=666")
    ExVCR.Config.filter_sensitive_data("_id=@w+", "_id=@group")
    :ok
  end

  test "create_account" do
    use_cassette "graph/create_account" do
      {:ok, account} = Nadia.Graph.create_account("some_short_name", "some_author_name")
      assert account.short_name == "some_short_name"
    end
  end

  test "edit_account_info" do
    use_cassette "graph/edit_account_info" do
      {:ok, account} =
        Nadia.Graph.edit_account_info(
          "b968da509bb76866c35425099bc0989a5ec3b32997d55286c657e6994bbb",
          "some_short_name",
          "some_author_name"
        )

      assert account.short_name == "some_short_name"
    end
  end

  test "get_account_info" do
    use_cassette "graph/get_account_info" do
      {:ok, account} =
        Nadia.Graph.get_account_info(
          "b968da509bb76866c35425099bc0989a5ec3b32997d55286c657e6994bbb",
          ["short_name", "page_count"]
        )

      assert account.short_name == "some_short_name"
    end
  end

  test "revoke_access_token" do
    use_cassette "graph/revoke_access_token" do
      {:ok, account} =
        Nadia.Graph.revoke_access_token(
          "b968da509bb76866c35425099bc0989a5ec3b32997d55286c657e6994bbb"
        )

      assert account.short_name == "some_short_name"
    end
  end

  test "get_page_list" do
    use_cassette "graph/get_page_list" do
      {:ok, page_list} =
        Nadia.Graph.get_page_list(
          "b968da509bb76866c35425099bc0989a5ec3b32997d55286c657e6994bbb",
          0,
          3
        )

      assert page_list.total_count == 1058
      assert hd(page_list.pages).path == "Sample-Page-01-13-6"
    end
  end

  test "create_page" do
    use_cassette "graph/create_page" do
      {:ok, page} =
        Nadia.Graph.create_page(
          "b968da509bb76866c35425099bc0989a5ec3b32997d55286c657e6994bbb",
          "Sample Page",
          "[{\"tag\":\"p\",\"children\":[\"Hello,+world!\"]}]"
        )

      assert page.title == "Sample Page"
    end
  end

  test "get_page" do
    use_cassette "graph/get_page" do
      {:ok, page} = Nadia.Graph.get_page("Sample-Page-12-15")
      assert page.title == "Sample Page"
      assert page.content != nil
    end
  end

  test "edit_page" do
    use_cassette "graph/edit_page" do
      {:ok, page} =
        Nadia.Graph.edit_page(
          "b968da509bb76866c35425099bc0989a5ec3b32997d55286c657e6994bbb",
          "Sample-Page-12-15",
          "Some Page2",
          "[{\"tag\":\"p\",\"children\":[\"Hello,+world!\"]}]"
        )

      assert page.title == "Sample Page2"
    end
  end

  test "get_views" do
    use_cassette "graph/get_views" do
      {:ok, result} = Nadia.Graph.get_views("Sample-Page-12-15", year: 2012, month: 12)
      assert result.views == 40
    end
  end
end
