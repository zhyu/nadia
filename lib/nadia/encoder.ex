defimpl Jason.Encoder, for: Nadia.Model.InlineKeyboardButton do
  def encode(button, options) do
    Map.from_struct(button)
    |> reject_nil
    |> Jason.Encoder.encode(options)
  end

  defp reject_nil(map) do
    :maps.filter(fn _, v -> !is_nil(v) end, map)
  end
end
