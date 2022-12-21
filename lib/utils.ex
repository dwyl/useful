# Gist module from https://gist.github.com/mpugach/2d264c063db9bc91af0f7c7ec8175037
defmodule MapFromDeepStruct do
  def from_deep_struct(%{} = map), do: convert(map)

  defp convert(data) when is_struct(data) do
    data |> Map.from_struct() |> convert()
  end

  defp convert(data) when is_map(data) do
    for {key, value} <- data, reduce: %{} do
      acc ->
        case key do
          :__meta__ ->
            acc

          other ->
            Map.put(acc, other, convert(value))
        end
    end
  end

  defp convert(other), do: other
end
