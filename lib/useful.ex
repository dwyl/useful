defmodule Useful do
  @moduledoc """
  A Library of `Useful` functions for building `Elixir` Apps.
  """

  @doc """
  `atomize_map_keys/1` converts a `Map` with different keys
  to a map with just atom keys. Works recursively for nested maps.
  Inspired by https://stackoverflow.com/questions/31990134

  ## Examples

      iex> Useful.atomize_map_keys(%{"name" => "alex", id: 1})
      %{id: 1, name: "alex"}

      iex> Useful.atomize_map_keys(%{"name" => "alex", data: %{ "age" => 17}})
      %{name: "alex", data: %{age: 17}}

  """
  def atomize_map_keys(%Date{} = value), do: value
  def atomize_map_keys(%Time{} = value), do: value
  def atomize_map_keys(%DateTime{} = value), do: value
  def atomize_map_keys(%NaiveDateTime{} = value), do: value
  # Avoid Plug.Upload.__struct__/0 is undefined compilation error
  # [useful#52](https://github.com/dwyl/useful/issues/52)
  # alias Plug.Upload
  def atomize_map_keys(%Plug.Upload{} = value), do: value

  # handle lists in maps:
  # [useful#46](https://github.com/dwyl/useful/issues/46)
  def atomize_map_keys(items) when is_list(items) do
    for i <- items do
      atomize_map_keys(i)
    end
  end

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
  `empty_dir_contents/1` delete all files including any directories
  recursively in a dir but not the dir itself.

  Very happy for anyone to refactor this function to something pretty.
  """
  def empty_dir_contents(dir) do
    cond do
      is_nil(dir) ->
        {:error, "dir supplied to Useful.empty_dir_contents/1 is nil"}

      not File.dir?(dir) ->
        {:error, "#{dir} arg to Useful.empty_dir_contents/1 not a directory"}

      true ->
        # read contents of directory:
        {:ok, list} = File.ls(dir)

        Enum.each(list, fn f ->
          path = Path.join([dir, f]) |> Path.expand()

          cond do
            # delete all dirs recursively:
            File.dir?(path) ->
              File.rm_rf(path)

            # delete any files in the dir:
            File.exists?(path) ->
              File.rm(path)
          end
        end)

        {:ok, dir}
    end
  end

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
  `get_in_default/3` Proxies `Kernel.get_in/2`
  but allows setting a `default` value as the 3rd argument.

  ## Examples

      iex> map = %{name: "alex", data: %{age: 17, height: 185}}
      iex> Useful.get_in_default(map, [:data, :age])
      17
      iex> Useful.get_in_default(map, [:data, :iq], 180)
      180
      iex> Useful.get_in_default(nil, [:unhappy, :path], "Happy!")
      "Happy!"
  """
  def get_in_default(map, keys, default \\ nil) do
    # https://hexdocs.pm/elixir/1.14/Kernel.html#get_in/2
    # Enum.each(keys, )
    try do
      case get_in(map, keys) do
        nil -> default
        result -> result
      end
    rescue
      _ ->
        default
    end
  end

  @doc """
  `list_tuples_to_unique_keys/1` turns a list of tuples
  with the same key into a list of tuples with unique keys.
  Useful when dealing with "multipart" forms that upload multiple files.

  ## Example

      iex> parts = [{"file", "header", "pic1.png"}, {"file", "header", "pic2.png"}]
      iex> Useful.list_tuples_to_unique_keys(parts)
      [{"file-1", "header", "pic1.png"}, {"file-2", "header", "pic2.png"}]
  """
  def list_tuples_to_unique_keys(parts) do
    key = parts |> hd() |> elem(0)
    new_keys = Enum.map(1..length(parts), &(key <> "-#{&1}"))

    Enum.zip_reduce([parts, new_keys], [], fn [elt, new_key], acc ->
      [
        elt |> Tuple.delete_at(0) |> Tuple.insert_at(0, new_key)
        | acc
      ]
    end)
    |> Enum.sort()
  end

  @doc """
  `remove_item_from_list/2` removes a given `item` from a `list` in any position.

  ## Examples

      iex> list = ["They'll", "never", "take", "our", "freedom!"]
      iex> Useful.remove_item_from_list(list, "never")
      ["They'll", "take", "our", "freedom!"]

  """
  def remove_item_from_list(list, item) do
    if Enum.member?(list, item) do
      i = Enum.find_index(list, fn it -> it == item end)
      List.delete_at(list, i)
    else
      list
    end
  end

  @doc """
  `stringy_map/1` converts a `Map` of any depth/nesting into a string.
  Deeply nested maps are denoted by "__" (double underscore). See flatten_map/1
  for more details.
  Alphabetizes the keys for consistency.
  See: [useful#56](https://github.com/dwyl/useful/issues/56)

  ## Examples

      iex> map = %{name: "alex", data: %{age: 17, height: 185}}
      iex> Useful.stringify_map(map)
      "data__age: 17, data__height: 185, name: alex"

  """
  def stringify_map(map) when is_nil(map), do: "nil"

  def stringify_map(map) when is_map(map) do
    map
    |> flatten_map()
    |> Enum.sort()
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
  `truncate/3` truncates an `input` (`String`) to desired `length` (`Number`).
  _Optional_ third param `terminator` defines what comes after truncated text.
  The default is "..." but any alternative can be defined; see examples below.

  Don't cut a string mid-word e.g: "I like to eat shiitaki mushrooms"
  should not be truncated to "I like to eat shiit..."
  Rather, it should truncate to: "I like to eat ..."
  I'm sure you can think of more examples, but you get the idea.

  ## Examples

      iex> input = "A room without books is like a body without a soul."
      iex> Useful.truncate(input, 29)
      "A room without books is like..."

      iex> input = "do or do not there is no try"
      iex> Useful.truncate(input, 12, "") # no ellipsis
      "do or do not"

  """
  # Header with default value for terminator
  def truncate(input, length, terminator \\ "...")

  def truncate(input, _length, _terminator) when not is_binary(input) do
    # return the input unmodified
    input
  end

  def truncate(input, length, _terminator) when not is_number(length) do
    # return the input unmodified if length is NOT a number
    input
  end

  def truncate(input, _length, terminator) when not is_binary(terminator) do
    # return the input unmodified
    input
  end

  def truncate(input, length, terminator) do
    cond do
      # avoid processing invalid binaries, return input early:
      # hexdocs.pm/elixir/1.12/String.html#valid?/1
      !String.valid?(input) ->
        input

      # input is less than length, return full input early:
      String.length(input) <= length ->
        input

      # input is valid and longer than `length`, attempt to truncate it:
      true ->
        # Slice the input string at the end of `length`:
        sliced = String.slice(input, 0..(length - 1))
        # dbg(sliced)
        # Get character at the position of `length` in the input string:
        char_at = String.at(input, length)
        # Check if character at end of the truncated string is whitespace:
        sliced =
          if Regex.match?(~r/\p{Zs}/u, char_at) do
            sliced
          else
            # Character at the end of the truncated string is NOT whitespace
            # since we don't want to cut a word in half, we instead find a space.
            # Find the last whitespace character nearest (before) `length`:
            # Regex: https://elixirforum.com/t/detect-char-whitespace/26735/5
            # Try it in iex:
            # > Regex.scan(~r/\p{Zs}/u, "foo bar baz", return: :index)
            # > [[{3, 1}], [{7, 1}]]
            [{index, _}] =
              Regex.scan(~r/\p{Zs}/u, sliced, return: :index)
              |> List.last()

            String.slice(input, 0..(index - 1))
          end

        "#{sliced}#{terminator}"
    end
  end

  @doc """
  `typeof/1` returns the type of a variable.
  Inspired by https://stackoverflow.com/questions/28377135/typeof-var-elixir

  ## Examples

      iex> Useful.typeof(:atom)
      "atom"

      iex> bin = "hello"
      iex> Useful.typeof(bin)
      "binary"

      iex> bitstr = <<1::3>>
      iex> Useful.typeof(bitstr)
      "bitstring"

      iex> Useful.typeof(:true)
      "boolean"

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

      iex> map = %{:foo => "bar", "hello" => :world}
      iex> Useful.typeof(map)
      "map"

      iex> Useful.typeof(nil)
      "nil"

      iex> pid = spawn(fn -> 1 + 2 end)
      iex> Useful.typeof(pid)
      "pid"

      iex> port = Port.open({:spawn, "cat"}, [:binary])
      iex> Useful.typeof(port)
      "port"

      iex> ref = :erlang.make_ref
      iex> Useful.typeof(ref)
      "reference"

      iex> tuple = {:name, "alex"}
      iex> Useful.typeof(tuple)
      "tuple"
  """
  types =
    ~w[boolean binary bitstring float function integer list map nil pid port reference tuple atom]

  for type <- types do
    def typeof(x) when unquote(:"is_#{type}")(x), do: unquote(type)
  end

  # No idea how to test this. Do you? ¯\_(ツ)_/¯
  # coveralls-ignore-start
  def typeof(_) do
    "unknown"
  end

  # coveralls-ignore-stop
end
