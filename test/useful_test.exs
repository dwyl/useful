defmodule UsefulTest do
  use ExUnit.Case, async: true
  doctest Useful

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
      map = %{"name" => "alex", data: %{ age: 17, benches: 200}}
      assert Useful.get_in_default(map, [:data, :age]) == 17
    end

    test "default when key not set" do
      map = %{"name" => "alex", data: %{ age: 17, benches: 200}}
      assert Useful.get_in_default(map, [:data, :iq], 180) == 180
    end

    test "default when no keys are defined" do
      map = %{"name" => "alex", data: %{ age: 17, benches: 200}}
      assert Useful.get_in_default(map, [:this, :that], 42) == 42
    end

    test "really unhappy path still returns default value!" do
      assert Useful.get_in_default(nil, [:foo, :bar], 42) == 42
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
      map = %{id: 1, data: %{name: "Vitor", other: %{data: "info"}}}
      assert Useful.stringify_map(map) == "data__name: Vitor, data__other__data: info, id: 1"
    end

    test "converts nested lists into strings" do
      map = %{id: 1, data: %{names: ["Vitor", "alex"]}}
      assert Useful.stringify_map(map) == "data__names: \"Vitor, alex\", id: 1"
    end
  end

  describe "typeof/1" do
    test "returns \"atom\" for an :atom" do
      assert Useful.typeof(:atom) == "atom"
    end

    #  recap: https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html
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
end
