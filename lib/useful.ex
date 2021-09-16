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
  `flatten_map/1` flattens a `Map` of any depth/nesting for easier processing.
  Deeply nested maps are denoted by "__" (double underscore) e.g:
  `%{name: Alex, detail: %{age: 17}}` becomes `%{name: Alex, detail__age: 17}`
  this makes it easy to see what the data structure was before flattening.
  Map keys are converted to Atom for simpler access and consistency.
  Inspired by: https://stackoverflow.com/questions/39401947/flatten-nested-map

  ## Examples

      iex> map = %{name: "alex", data: %{age: 17, height: 185}}
      iex> Useful.flatten_map(map)
      %{data__age: 17, data__height: 185, name: "alex"}

  """
  def flatten_map(map) when is_map(map) do
    map
    |> to_list_of_tuples
    |> Enum.map(&key_to_atom/1)
    |> Enum.into(%{})
  end

  @doc """
  `stringy_map/1` converts a `Map` of any depth/nesting into a string.
  Deeply nested maps are denoted by "__" (double underscore). See flatten_map/1
  for more details.

  ## Examples

      iex> map = %{name: "alex", data: %{age: 17, height: 185}}
      iex> Useful.stringify_map(map)
      "data__age: 17, data__height: 185, name: alex"

  """
  def stringify_map(map) when is_nil(map), do: "nil"

  def stringify_map(map) when is_map(map) do
    map
    |> flatten_map()
    |> Enum.map(&stringify_tuple/1)
    |> Enum.join(", ")
  end


  @doc """
  `stringify_tuple/1` stringifies a `Tuple` with arbitrary values.
  Handy when you want to print out a tuple during debugging.

  ## Examples

      iex> tuple = {:name, "alex"}
      iex> Useful.stringify_tuple(tuple)
      "name: alex"
  """
  def stringify_tuple({key, values}) when is_list(values) do
    text = Enum.join(values, ", ")
    stringify_tuple({key, "\"#{text}\""})
  end

  def stringify_tuple({key, value}) do
    "#{key}: #{value}"
  end

  # Recap: https://elixir-lang.org/getting-started/basic-types.html#tuples
  defp to_list_of_tuples(map) do
    map
    |> Enum.map(&process/1)
    |> List.flatten()
  end

  # avoids the error "** (Protocol.UndefinedError) protocol Enumerable
  #   not implemented for ~U[2017-08-05 16:34:08.003Z] of type DateTime"
  defp process({key, %Date{} = date}), do: {key, date}
  defp process({key, %DateTime{} = datetime}), do: {key, datetime}

  # process nested maps
  defp process({key, sub_map}) when is_map(sub_map) do
    for {sub_key, value} <- flatten_map(sub_map) do
      {"#{key}__#{sub_key}", value}
    end
  end

  # catch-all for any type of key/value
  defp process({key, value}), do: {key, value}

  # Converts the {key: value} with Atom key for simpler access
  defp key_to_atom({key, value}) do
    {String.to_atom("#{key}"), value}
  end


  @doc """
  `typeof/1` returns the type of a vairable.
  Inspired by stackoverflow.com/questions/28377135/check-typeof-variable-in-elixir

  ## Examples

      iex> Useful.typeof(:atom)
      "atom"

      iex> bin = "hello"
      iex> Useful.typeof(bin)
      "binary"

      iex> pi = 3.14159
      iex> Useful.typeof(pi)
      "float"

      iex> fun = fn (a, b) -> a + b end
      iex> Useful.typeof(fun)
      "function"

      iex> Useful.typeof(&Useful.typeof/1)
      "function"

      iex> int = 42
      iex> Useful.typeof(int)
      "integer"

      iex> list = [1,2,3,4]
      iex> Useful.typeof(list)
      "list"

  """
  types = ~w[atom binary bitstring float function integer list map nil pid port reference tuple]
  for type <- types do
    def typeof(x) when unquote(:"is_#{type}")(x), do: unquote(type)
  end
end
