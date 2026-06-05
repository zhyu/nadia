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

  defp parse(type, val) when is_map(val) do
    fields = struct_fields(type)

    entries =
      val
      |> Enum.flat_map(&known_struct_entry(&1, fields))
      |> Enum.map(&parse(&1))

    struct(type, entries)
  end

  defp parse({:pages, val}) when is_list(val), do: {:pages, Enum.map(val, &parse(Page, &1))}
  defp parse(others), do: others

  defp struct_fields(type) do
    type
    |> struct()
    |> Map.keys()
    |> Enum.reject(&(&1 == :__struct__))
  end

  defp known_struct_entry({key, val}, fields) when is_atom(key) do
    if key in fields, do: [{key, val}], else: []
  end

  defp known_struct_entry({key, val}, fields) when is_binary(key) do
    case Enum.find(fields, &(Atom.to_string(&1) == key)) do
      nil -> []
      field -> [{field, val}]
    end
  end
end
