defimpl Poison.Encoder, for: Nadia.Model.InlineKeyboardButton do
  def encode(button, options) do
    Map.from_struct(button)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new
    |> Poison.Encoder.encode(options)
  end
end
