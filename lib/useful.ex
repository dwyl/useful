defmodule Useful do
  @moduledoc """
  A Library of `Useful` functions for building `Elixir` Apps.
  """

  @doc """
  `atomize_map_keys/1` converts a map with different keys 
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
end
