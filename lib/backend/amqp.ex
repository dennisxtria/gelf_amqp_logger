defmodule Backend.AMQP do
  @moduledoc false

  alias Backend.RabbitMQ
  alias Utils

  @_facility 1
  @host Config.connection_host()
  @version "1.1"

  def log_event(level, message, timestamp, metadata, channel) do
    level
    |> build_gelf_map(message, timestamp, metadata)
    |> to_json()
    |> RabbitMQ.publish_gelf(channel)
  end

  def build_gelf_map(level, message, timestamp, metadata) do
    full_message = to_string(message)
    int_level = Utils.level_to_int(level)
    unix_timestamp = Utils.to_unix(timestamp)
    metadata_fields = Utils.create_additional_fields(metadata)

    %{
      _facility: @_facility,
      full_message: full_message,
      host: @host,
      level: int_level,
      short_message: String.slice(full_message, 0..79),
      timestamp: unix_timestamp,
      version: @version
    }
    |> Map.merge(metadata_fields)
  end

  def to_json(gelf_message), do: Jason.encode!(gelf_message)
end
