defmodule Backend.AMQP do
  @moduledoc false

  alias Backend.RabbitMQ
  alias Messages.Gelf
  alias Utils

  @host Config.connection_host()
  @file_line [:file, :line]

  def log_event(level, message, timestamp, metadata, channel) do
    level
    |> build_gelf_map(message, timestamp, metadata)
    |> Gelf.new()
    |> Gelf.to_json()
    |> RabbitMQ.publish_gelf(channel)
  end

  @doc ~S"""
  Builds a map that consists of all the necessary information
  according to GELF 1.1 sepcification.

  ## Examples

      iex> metadata = [
      ...>   pid: 22,
      ...>   line: 102,
      ...>   function: "xrmq_open_channel/1",
      ...>   module: Ariadne.BetslipService.API.Producer,
      ...>   file: "lib/ex_rabbit_m_q/a_s_t/common.ex",
      ...>   application: :ariadne_betslip_service
      ...>   ]
      iex> timestamp = {{2019, 3, 10}, {11, 6, 23, 345}}
      iex> Backend.AMQP.build_gelf_map(:info, "example message", timestamp, metadata)
      %{
        file: "lib/ex_rabbit_m_q/a_s_t/common.ex",
        full_message: "example message",
        host: "localhost",
        level: 6,
        line: 102,
        short_message: "example message",
        timestamp: 1552215983.345
      }
  """
  def build_gelf_map(level, message, timestamp, metadata) do
    int_level = Utils.level_to_int(level)
    unix_timestamp = Utils.to_unix(timestamp)

    %{
      full_message: to_string(message),
      host: @host,
      level: int_level,
      short_message: String.slice(message, 0..79),
      timestamp: unix_timestamp
    }
    |> fill_file_line_if_present(metadata)
  end

  defp fill_file_line_if_present(gelf_map, metadata) do
    Enum.reduce(@file_line, gelf_map, fn x, gelf_map ->
      result = Keyword.get(metadata, x)

      case result do
        nil -> Map.put(gelf_map, x, nil)
        _ -> Map.put(gelf_map, x, result)
      end
    end)
  end
end
