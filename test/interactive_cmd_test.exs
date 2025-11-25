defmodule InteractiveCmdTest do
  use ExUnit.Case
  doctest InteractiveCmd

  test "greets the world" do
    assert InteractiveCmd.hello() == :world
  end
end
