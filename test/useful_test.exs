defmodule UsefulTest do
  use ExUnit.Case
  doctest Useful

  test "atomize_map_keys/1 converts string keys to map" do
    map = %{"name" => "alex", id: 1}
    # IO.inspect(map, label: "map")
    assert Useful.atomize_map_keys(map) == %{id: 1, name: "alex"}
  end

  test "atomize_map_keys/1 converts deeply nested map" do
    map = %{"name" => "alex", id: 1, nested: %{ "age" => 17, height: 185}}
    # IO.inspect(map, label: "map")
    expected = Useful.atomize_map_keys(map)
    assert expected == %{id: 1, name: "alex", nested: %{age: 17, height: 185}}
  end

  test "flatten_map/1 flattens a deeply nested map" do
    map = %{name: "alex", data: %{age: 17, height: 185}}
    expected = Useful.flatten_map(map)
    assert expected == %{"name" => "alex", "data.age" => 17, "data.height" => 185}
  end

  test "flatten_map/1 handles Date and DateTime values" do
    map = %{
      date: Date.from_erl!({2000, 1, 1}),
      data: %{
        dateTime: DateTime.from_naive!(~N[2016-05-24 13:26:08.003], "Etc/UTC"),
        height: 185}
      }
    expected = Useful.flatten_map(map)
    assert expected == %{
      "date" => ~D[2000-01-01],
      "data.dateTime" => ~U[2016-05-24 13:26:08.003Z],
      "data.height" => 185
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
      "data.address.detail.house_color" => "white",
      "data.address.detail.more_info.architect" => "James Hoban",
      "data.address.first_line" => "1600 Pennsylvania Avenue",
      "data.address.post_code" => "20500",
      "name" => "Alex"
    }
  end
end