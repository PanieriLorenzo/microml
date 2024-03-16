defmodule MicromlTest do
  use ExUnit.Case
  doctest Microml

  test "greets the world" do
    assert Microml.hello() == :world
  end
end
