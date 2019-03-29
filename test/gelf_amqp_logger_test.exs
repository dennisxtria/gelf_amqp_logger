defmodule GelfAmqpLoggerTest do
  use ExUnit.Case
  doctest GelfAmqpLogger

  test "greets the world" do
    assert GelfAmqpLogger.hello() == :world
  end
end
