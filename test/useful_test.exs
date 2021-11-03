defmodule UsefulTest do
  use ExUnit.Case
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
