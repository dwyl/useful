defmodule Useful do
  @moduledoc """
  A Library of `Useful` functions for building `Elixir` Apps.
  """

  @doc """
  `atomize_map_keys/1` converts a `Map` with different keys
  to a map with just atom keys. Works recursively for nested maps.
  Inspired by stackoverflow.com/questions/31990134

  ## Examples

      iex> Useful.atomize_map_keys(%{"name" => "alex", id: 1})
      %{id: 1, name: "alex"}

      iex> Useful.atomize_map_keys(%{"name" => "alex", data: %{ "age" => 17}})
      %{name: "alex", data: %{age: 17}}

  """
  def atomize_map_keys(map) when is_map(map) do
    for {key, val} <- map, into: %{} do
      cond do
        is_atom(key) -> {key, atomize_map_keys(val)}
        true -> {String.to_atom(key), atomize_map_keys(val)}
      end
    end
  end

  def atomize_map_keys(value), do: value

  @doc """
  `flatten_map/1` flattens a `Map` of any depth
  Inspired by: https://stackoverflow.com/questions/39401947/flatten-nested-map

  ## Examples

      iex> map = %{name: "alex", data: %{age: 17, height: 185}}
      iex> Useful.flatten_map(map)
      %{"name" => "alex", "data.age" => 17, "data.height" => 185}

  """
  def flatten_map(map) when is_map(map) do
    map
    |> to_list_of_tuples
    |> Enum.into(%{})
  end

  defp to_list_of_tuples(map) do
    map
    |> Enum.map(&process/1)
    |> List.flatten()
  end

  defp process({key, %DateTime{} = datetime}), do: {"#{key}", datetime}
  defp process({key, %Date{} = date}), do: {"#{key}", date}

  defp process({key, sub_map}) when is_map(sub_map) do
    for {sub_key, value} <- flatten_map(sub_map) do
      {"#{key}.#{sub_key}", value}
    end
  end

  defp process({key, value}), do: {"#{key}", process(value)}
  defp process(value), do: value
end
