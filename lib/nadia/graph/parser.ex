defmodule Nadia.Graph.Parser do
  @moduledoc """
  Provides parser logics for API results.
  """

  alias Nadia.Graph.Model.{Account, PageList, Page, PageViews}

  @doc """
  parse `result` field of decoded API response json.

  Args:
  * `result` - `result` field of decoded API response json
  * `method` - name of API method
  """
  def parse_result(result, method) do
    case method do
      "createAccount" -> parse(Account, result)
      "editAccountInfo" -> parse(Account, result)
      "getAccountInfo" -> parse(Account, result)
      "revokeAccessToken" -> parse(Account, result)
      "createPage" -> parse(Page, result)
      "editPage/" <> _ -> parse(Page, result)
      "getPage/" <> _ -> parse(Page, result)
      "getPageList" -> parse(PageList, result)
      "getViews/" <> _ -> parse(PageViews, result)
    end
  end

  defp parse(type, val), do: struct(type, Enum.map(val, &parse(&1)))
  defp parse(others), do: others
end
