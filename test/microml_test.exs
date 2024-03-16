defmodule MicroMLTest do
  use ExUnit.Case
  doctest MicroML

  test "greets the world" do
    assert MicroML.hello() == :world
  end
end
