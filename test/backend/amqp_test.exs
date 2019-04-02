defmodule Backend.AMQPTest do
  @moduledoc false

  use ExUnit.Case

  alias Backend.AMQP

  doctest Backend.AMQP

  @_facility 1
  @file_name "lib/ex_rabbit_m_q/a_s_t/common.ex"
  @function_name "xrmq_open_channel/1"
  @line_number :rand.uniform(100)
  @localhost "localhost"
  @log_level 6
  @message "example message"
  @pid self()
  @timestamp {{2019, 3, 10}, {11, 6, 23, 345}}
  @unix_timestamp 1_552_215_983.345
  @version "1.1"

  test "empty file and empty line", do: assert(valid_gelf_map?(nil, ""))
  test "empty file", do: assert(valid_gelf_map?(@line_number, ""))
  test "empty line", do: assert(valid_gelf_map?(nil, @file_name))
  test "both present", do: assert(valid_gelf_map?(@line_number, @file_name))

  defp valid_gelf_map?(line_number, file_name) do
    metadata = new_metadata(line_number, file_name)

    gelf_map = AMQP.build_gelf_map(:info, @message, @timestamp, metadata)

    assert gelf_map == new_test_gelf_map(line_number, file_name)
  end

  defp new_test_gelf_map(line_number, file_name) do
    line_number = if line_number != nil, do: Integer.to_string(line_number), else: ""
    file_name = if file_name != nil, do: file_name, else: ""

    %{
      :_facility => @_facility,
      :full_message => @message,
      :host => @localhost,
      :level => @log_level,
      :short_message => @message,
      :timestamp => @unix_timestamp,
      :version => @version,
      "_application" => to_string(:ariadne_betslip_service),
      "_file" => file_name,
      "_function" => @function_name,
      "_line" => line_number,
      "_module" => to_string(Ariadne.BetslipService.API.Producer),
      "_pid" => inspect(@pid)
    }
  end

  defp new_metadata(line_number, file_name) do
    [
      application: :ariadne_betslip_service,
      file: file_name,
      function: @function_name,
      line: line_number,
      module: Ariadne.BetslipService.API.Producer,
      pid: @pid
    ]
  end
end
