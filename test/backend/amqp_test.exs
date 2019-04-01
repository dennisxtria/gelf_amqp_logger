defmodule Backend.AMQPTest do
  @moduledoc false

  use ExUnit.Case

  doctest Backend.AMQP

  @file_name "lib/ex_rabbit_m_q/a_s_t/common.ex"
  @function_name "xrmq_open_channel/1"
  @line_number :rand.uniform(100)
  @localhost "localhost"
  @log_level 6
  @message "example message"
  @pid :rand.uniform(100)
  @timestamp {{2019, 3, 10}, {11, 6, 23, 345}}
  @unix_timestamp 1_552_215_983.345

  test "empty file and empty line", do: assert(valid_gelf_map?(nil, nil))
  test "empty file", do: assert(valid_gelf_map?(@line_number, nil))
  test "empty line", do: assert(valid_gelf_map?(nil, @file_name))
  test "both present", do: assert(valid_gelf_map?(@line_number, @file_name))

  defp valid_gelf_map?(line_number, file_name) do
    metadata = new_metadata(line_number, file_name)

    gelf_map = Backend.AMQP.build_gelf_map(:info, @message, @timestamp, metadata)

    assert gelf_map == new_test_gelf_map(line_number, file_name)
  end

  defp new_test_gelf_map(line, file_name) do
    %{
      file: file_name,
      full_message: @message,
      host: @localhost,
      level: @log_level,
      line: line,
      short_message: @message,
      timestamp: @unix_timestamp
    }
  end

  defp new_metadata(line, file_name) do
    [
      pid: @pid,
      function: @function_name,
      line: line,
      module: Ariadne.BetslipService.API.Producer,
      file: file_name,
      application: :ariadne_betslip_service
    ]
  end
end
