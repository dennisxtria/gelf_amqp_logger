defmodule Messages.GelfTest do
  @moduledoc false

  use ExUnit.Case

  alias Messages.Gelf

  @_facility 1
  @file_name "lib/ex_rabbit_m_q/a_s_t/common.ex"
  @function_name "xrmq_open_channel/1"
  @line_number :rand.uniform(100)
  @localhost "localhost"
  @log_level 6
  @message "example message"
  @pid :rand.uniform(100)
  @timestamp {{2019, 3, 10}, {11, 6, 23, 345}}
  @unix_timestamp 1_552_215_983.345
  @version "1.1"

  describe "transformation from map to Messages.Gelf struct" do
    test "empty line and empty file", do: assert(valid_gelf_struct?(nil, nil))
    test "empty file", do: assert(valid_gelf_struct?(@line_number, nil))
    test "empty line", do: assert(valid_gelf_struct?(nil, @file_name))

    test "both present",
      do: assert(valid_gelf_struct?(@line_number, @file_name))
  end

  describe "transformation from map to json" do
    test "all fields are present" do
      gelf = new_gelf_struct(@line_number, @file_name)

      json =
        "{\"_facility\":1,\"file\":\"#{@file_name}\",\"full_message\":\"example message\",\"host\":\"localhost\",\"level\":6,\"line\":#{
          @line_number
        },\"short_message\":\"example message\",\"timestamp\":1552215983.345,\"version\":\"1.1\"}"

      assert Gelf.to_json(gelf) == json
    end

    test "file key is nil" do
      gelf = new_gelf_struct(@line_number, nil)

      json =
        "{\"_facility\":1,\"file\":null,\"full_message\":\"example message\",\"host\":\"localhost\",\"level\":6,\"line\":#{
          @line_number
        },\"short_message\":\"example message\",\"timestamp\":1552215983.345,\"version\":\"1.1\"}"

      assert Gelf.to_json(gelf) == json
    end

    test "line key is nil" do
      gelf = new_gelf_struct(nil, @file_name)

      json =
        "{\"_facility\":1,\"file\":\"#{@file_name}\",\"full_message\":\"example message\",\"host\":\"localhost\",\"level\":6,\"line\":null,\"short_message\":\"example message\",\"timestamp\":1552215983.345,\"version\":\"1.1\"}"

      assert Gelf.to_json(gelf) == json
    end
  end

  defp valid_gelf_struct?(line_number, file_name) do
    metadata = new_metadata(line_number, file_name)

    gelf_map = Backend.AMQP.build_gelf_map(:info, @message, @timestamp, metadata)

    Messages.Gelf.new(gelf_map) == new_gelf_struct(line_number, file_name)
  end

  defp new_gelf_struct(line_number, file_name) do
    %Gelf{
      _facility: @_facility,
      file: file_name,
      full_message: @message,
      host: @localhost,
      level: @log_level,
      line: line_number,
      short_message: @message,
      timestamp: @unix_timestamp,
      version: @version
    }
  end

  defp new_metadata(line_number, file_name) do
    [
      pid: @pid,
      function: @function_name,
      line: line_number,
      module: Santa,
      file: file_name,
      application: :santa_registry
    ]
  end
end
