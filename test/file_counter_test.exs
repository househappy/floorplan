defmodule Floorplan.FileCounterTest do
  use ExUnit.Case

  alias Floorplan.FileCounter

  setup do
    FileCounter.reset
    :ok
  end

  test "returns the current count and increments by one" do
    assert FileCounter.increment == 1
    assert FileCounter.increment == 2
    assert FileCounter.increment == 3
  end
end
