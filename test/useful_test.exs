defmodule UsefulTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest Useful

  test "list_tuples_to_unique_keys/1 makes unique keys" do
    parts = [
      {"files",
       [
         {"content-type", "image/png"},
         {"content-disposition", "form-data; name=\"files\"; filename=\"first.png\""}
       ], %Plug.Upload{path: "..", content_type: "image/png", filename: "first.png"}},
      {"files",
       [
         {"content-type", "image/webp"},
         {"content-disposition", "form-data; name=\"files\"; filename=\"second.webp\""}
       ], %Plug.Upload{path: "...", content_type: "image/webp", filename: "second.webp"}}
    ]

    expected = [
      {"files-1",
       [
         {"content-type", "image/png"},
         {"content-disposition", "form-data; name=\"files\"; filename=\"first.png\""}
       ], %Plug.Upload{path: "..", content_type: "image/png", filename: "first.png"}},
      {"files-2",
       [
         {"content-type", "image/webp"},
         {"content-disposition", "form-data; name=\"files\"; filename=\"second.webp\""}
       ], %Plug.Upload{path: "...", content_type: "image/webp", filename: "second.webp"}}
    ]

    assert Useful.list_tuples_to_unique_keys(parts) == expected
  end

  test "atomize_map_keys/1 converts string keys to map" do
    map = %{"name" => "alex", id: 1}
    # IO.inspect(map, label: "map")
    assert Useful.atomize_map_keys(map) == %{id: 1, name: "alex"}
  end

  test "atomize_map_keys/1 converts deeply nested map" do
    map = %{"name" => "alex", id: 1, nested: %{"age" => 17, height: 185}}
    # IO.inspect(map, label: "map")
    expected = Useful.atomize_map_keys(map)
    assert expected == %{id: 1, name: "alex", nested: %{age: 17, height: 185}}
  end

  test "atomize_map_keys/1 handles Date, Time, DateTime and NaiveDateTime" do
    map = %{
      date: ~D[2023-03-30],
      time: ~T[12:00:00],
      naive_date_time: ~N[2023-03-30 12:00:00],
      date_time: ~U[2023-03-30 12:00:00Z]
    }

    assert Useful.atomize_map_keys(map) == map
  end

  test "atomize_map_keys/1 handles Plug.Upload" do
    map = %{
      image: %Plug.Upload{
        path: "path/to/file",
        filename: "file_name.ext",
        content_type: "application/pdf"
      }
    }

    assert Useful.atomize_map_keys(map) == map
  end

  test "atomize_map_keys/1 converts map containing list of maps" do
    map = %{
      "items" => [
        %{"text" => "hello world", atom: "works"},
        %{"text" => "camelCase", "backgroundColor" => "#9fe1e7"},
        %{"text" => "underscore_in_key", "inserted_at" => "2023-03-20T02:00:00Z"}
      ],
      "name" => "alex",
      id: 1,
      nested: %{"age" => 17, height: 185}
    }

    # dbg(map)
    actual = Useful.atomize_map_keys(map)
    # dbg(actual)
    first_item_actual = List.first(actual.items)
    first_item_expected = %{text: "hello world", atom: "works"}
    assert first_item_expected == first_item_actual

    last_item_actual = List.last(actual.items)
    last_item_expected = %{text: "underscore_in_key", inserted_at: "2023-03-20T02:00:00Z"}
    assert last_item_expected == last_item_actual
  end

  defp write_files_in_dir(dir) do
    file_name = "test.txt"
    file_path = Path.join([dir, file_name]) |> Path.expand()
    content = "Hey Jude, don't make it bad. Take a sad song and make it better"
    File.write(file_path, content)
    # return file_path so we can use it in test
    file_path
  end

  # create test dir for empty_dir_contents/1 with files and sub dirs:
  defp create_test_dir do
    dir = "tmp/deeply/nested/dir/"
    # attempt to create deeply nested dir:
    File.mkdir_p(dir)
    write_files_in_dir("tmp")
    # create file
    write_files_in_dir(dir)
  end

  describe "empty_dir_contents/1" do
    test "returns {:error, msg} if dir is nil" do
      {:error, msg} = Useful.empty_dir_contents(nil)
      assert String.contains?(msg, "nil")
    end

    test "returns {:error, msg} if dir arg is not a directory" do
      {:error, msg} = Useful.empty_dir_contents("not_dir")
      assert String.contains?(msg, "not a directory")
    end

    test "returns {:ok, dir} when directory successfully emptied" do
      dir_to_empty = "tmp"
      file_path = create_test_dir()
      # Confirm contents of test file:
      assert File.read!(file_path) |> String.contains?("Hey Jude")

      {:ok, dir} = Useful.empty_dir_contents(dir_to_empty)
      assert dir == dir_to_empty
      # Test file should not longer exist:
      assert not File.exists?(file_path)
      # But the dir itself should still be there:
      assert File.exists?(dir_to_empty)
    end
  end

  test "flatten_map/1 flattens a deeply nested map" do
    map = %{name: "alex", data: %{age: 17, height: 185}}
    expected = Useful.flatten_map(map)
    assert expected == %{data__age: 17, data__height: 185, name: "alex"}
  end

  test "flatten_map/1 handles Date and DateTime values" do
    map = %{
      date: Date.from_erl!({1999, 2, 14}),
      data: %{
        dateTime: DateTime.from_naive!(~N[2017-08-05 16:34:08.003], "Etc/UTC"),
        height: 185
      }
    }

    expected = Useful.flatten_map(map)

    assert expected == %{
             data__dateTime: ~U[2017-08-05 16:34:08.003Z],
             data__height: 185,
             date: ~D[1999-02-14]
           }
  end

  test "flatten super nested map" do
    map = %{
      name: "Alex",
      data: %{
        address: %{
          first_line: "1600 Pennsylvania Avenue",
          post_code: "20500",
          detail: %{
            house_color: "white",
            more_info: %{
              "architect" => "James Hoban"
            }
          }
        }
      }
    }

    expected = Useful.flatten_map(map)

    assert expected == %{
             data__address__detail__house_color: "white",
             data__address__detail__more_info__architect: "James Hoban",
             data__address__first_line: "1600 Pennsylvania Avenue",
             data__address__post_code: "20500",
             name: "Alex"
           }
  end

  describe "get_in_default/3" do
    test "happy path" do
      map = %{"name" => "alex", data: %{age: 17, benches: 200}}
      assert Useful.get_in_default(map, [:data, :age]) == 17
    end

    test "default when key not set" do
      map = %{"name" => "alex", data: %{age: 17, benches: 200}}
      assert Useful.get_in_default(map, [:data, :iq], 180) == 180
    end

    test "default when no keys are defined" do
      map = %{"name" => "alex", data: %{age: 17, benches: 200}}
      assert Useful.get_in_default(map, [:this, :that], 42) == 42
    end

    test "really unhappy path still returns default value!" do
      assert Useful.get_in_default(nil, [:foo, :bar], 42) == 42
    end

    test "Plug.Conn does not implement the Access behaviour" do
      conn = conn(:get, "/", "")
      assert Useful.get_in_default(conn, [:foo, :bar], 42) == 42
    end
  end

  describe "remove_item_from_list/2" do
    test "remove_item_from_list/2 removes a numeric item from a list" do
      list = [1, 2, 3, 4]
      # tl/1 = "tail of list" hexdocs.pm/elixir/1.15.5/Kernel.html#tl/1
      assert Useful.remove_item_from_list(list, 1) == tl(list)
    end

    test "remove_item_from_list/2 removes a numeric item in any position" do
      list = [1, 2, 3, 4]
      updated_list = [1, 2, 4]
      assert Useful.remove_item_from_list(list, 3) == updated_list
    end

    test "remove_item_from_list/2 removes an item from the list" do
      list = ["don't", "panic", "about", "climate", "change"]
      # tl/1 = "tail of list" hexdocs.pm/elixir/1.15.5/Kernel.html#tl/1
      assert Useful.remove_item_from_list(list, "don't") == tl(list)
    end

    test "attempt to remove_item_from_list/2 ignores item *not* in list" do
      item = "save"
      list = ["AI", "will", "destroy", "us"]
      assert Useful.remove_item_from_list(list, item) == list
    end
  end

  describe "stringfy_map/1" do
    test "returns nil string when map is nil" do
      assert Useful.stringify_map(nil) == "nil"
    end

    test "converts map into strings" do
      map = %{"name" => "alex", id: 1}
      assert Useful.stringify_map(map) == "id: 1, name: alex"
    end

    test "converts nested maps into strings" do
      map = %{id: 1, data: %{name: "Vitor", nested: %{data: "info"}}}
      assert Useful.stringify_map(map) == "data__name: Vitor, data__nested__data: info, id: 1"
    end

    test "converts nested lists into strings" do
      map = %{id: 1, data: %{names: ["Vitor", "alex"]}}
      assert Useful.stringify_map(map) == "data__names: \"Vitor, alex\", id: 1"
    end
  end

  describe "truncate/3" do
    test "truncates the string to the desired length and adds '...' " do
    end

    test "Returns the first argument unmodified if NOT a String" do
      # don't attempt to truncate an atom:
      assert Useful.truncate(:notstring, 42) == :notstring
    end

    test "Returns the first argument unmodified if length NOT number" do
      # don't attempt to truncate if length is not numeric:
      assert Useful.truncate("hello", :not_number) == "hello"
    end

    test "Returns the first argument unmodified if char NOT binary" do
      # don't attempt to truncate if length is not numeric:
      assert Useful.truncate("Hello Alex!", 42, :cat) == "Hello Alex!"
    end

    test "Returns early if input is not a valid string e.g: <<0xFFFF::16>>" do
      assert Useful.truncate(<<0xFFFF::16>>, 42, "") == <<0xFFFF::16>>
    end

    test "Don't truncate if input is less than length" do
      assert Useful.truncate("Hello World!", 42) == "Hello World!"
    end

    test "Don't truncate mid-word, find the previous whitespace" do
      input = "It's supercalifragilisticexpialidocious"
      truncated = Useful.truncate(input, 24)
      assert truncated == "It's..."
    end

    test "Returns the truncated string WITH trailing ellipsis" do
      input = "It was a bright cold day in April, and the clocks were striking"
      truncated = Useful.truncate(input, 24)
      assert truncated == "It was a bright cold day..."
    end

    test "Returns the truncated string WITHOUT trailing ellipsis" do
      input = "Three things were happening inside the Park on that Saturday"
      truncated = Useful.truncate(input, 27, "")
      assert truncated == "Three things were happening"
    end
  end

  describe "typeof/1" do
    test "returns \"atom\" for an :atom" do
      assert Useful.typeof(:atom) == "atom"
    end

    #  recap: https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html
    test "returns \"binary\" when variable is a binary" do
      string = "hello"
      assert Useful.typeof(string) == "binary"
    end

    # recap: https://elixir-lang.readthedocs.io/en/latest/intro/6.html#binaries-and-bitstrings
    test "returns \"bitstring\" when variable is a bitstring" do
      bitstr = <<1::size(1)>>
      assert Useful.typeof(bitstr) == "bitstring"
    end

    # "Every binary is a bitstring but every bitstring need not be a binary" ...

    test "returns \"float\" if the value is float" do
      golden = 1.618
      assert Useful.typeof(golden) == "float"
    end

    test "returns \"function\" when the variable is a function" do
      sum = fn a, b -> a + b end
      assert sum.(2, 3) == 5
      assert Useful.typeof(sum) == "function"

      assert Useful.typeof(&Useful.typeof/1) == "function"
    end

    test "list" do
      list = [1, 2, 3, 4]
      assert Useful.typeof(list) == "list"
    end

    test "map" do
      map = %{:foo => "bar", "hello" => :world}
      assert Useful.typeof(map) == "map"
    end

    test "nil" do
      assert Useful.typeof(nil) == "nil"
    end

    test "pid" do
      pid = spawn(fn -> 1 + 2 end)
      assert Useful.typeof(pid) == "pid"
    end

    # https://hexdocs.pm/elixir/1.12/Port.html
    test "port" do
      port = Port.open({:spawn, "cat"}, [:binary])
      assert Useful.typeof(port) == "port"
    end

    test "reference" do
      ref = :erlang.make_ref()
      assert Useful.typeof(ref) == "reference"
    end

    test "tuple" do
      tuple = {:name, "alex"}
      assert Useful.typeof(tuple) == "tuple"
    end
  end

  describe "is_valid_url?/1" do
    test "are URL valid" do
      assert Useful.is_valid_url?("http://www.google.com") == true
      assert Useful.is_valid_url?("http//google.com") == false
      assert Useful.is_valid_url?("ftp://google.com") == true
      assert Useful.is_valid_url?("https://google.com/api&url=ok") == true
      assert Useful.is_valid_url?("http://localhost:3000") == true
      assert Useful.is_valid_url?("https://localhost") == true
      assert Useful.is_valid_url?("htt:/google") == false
      assert Useful.is_valid_url?("www.google.com") == false
    end
  end
end
