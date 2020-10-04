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
    assert expected == %{data__age: 17, data__height: 185, name: "alex"}
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
      data__dateTime: ~U[2016-05-24 13:26:08.003Z],
      data__height: 185,
      date: ~D[2000-01-01]
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
end