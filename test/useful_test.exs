defmodule UsefulTest do
  use ExUnit.Case
  doctest Useful

  test "greets the world" do
    assert Useful.hello() == :world
  end
end
