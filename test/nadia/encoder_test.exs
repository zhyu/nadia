defmodule Nadia.EncoderTest do
  use ExUnit.Case, async: true

  alias Nadia.Model.{DisabledButton, EphemeralMessageParameters, InlineKeyboardButton}

  test "inline keyboard button excludes unknown keys as json" do
    json = Jason.encode!(%InlineKeyboardButton{})

    assert json == "{}"
  end

  test "inline keyboard button keeps disabled button field" do
    json =
      Jason.encode!(%InlineKeyboardButton{text: "Saved", disabled: %DisabledButton{}})

    assert json == ~s({"disabled":{},"text":"Saved"})
  end

  test "ephemeral message parameters exclude nil fields as json" do
    json =
      Jason.encode!(%EphemeralMessageParameters{
        receiver_user_id: 42,
        replace_callback_query_message: true
      })

    assert json == ~s({"receiver_user_id":42,"replace_callback_query_message":true})
  end
end
