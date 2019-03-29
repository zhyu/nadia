defmodule Nadia.Governor do

  def get_chat_id(update) do
    case update do
       %{inline_query: inline_query} when not is_nil(inline_query) ->
         inline_query.from.id
       %{callback_query: callback_query} when not is_nil(callback_query) ->
         callback_query.message.chat.id
       %{message: %{chat: %{id: id}}} when not is_nil(id) ->
         id
       %{edited_message: %{chat: %{id: id}}} when not is_nil(id) ->
         id
       %{channel_post: %{chat: %{id: id}}} when not is_nil(id) ->
         id
       _ -> raise "No chat id found!"
     end
    end

end
