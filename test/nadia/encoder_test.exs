defmodule Nadia.EncoderTest do
  use ExUnit.Case, async: true

  alias Nadia.Model.{InlineKeyboardButton}

  test "inline keyboard button excludes unknown keys as json" do
    json = Poison.encode!(%InlineKeyboardButton{})

    assert json == "{}"
  end
end
