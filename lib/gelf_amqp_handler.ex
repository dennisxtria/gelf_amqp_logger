defmodule GelfAMQPHandler do
  @moduledoc """
  A handler backend that will generate Graylog Extended Log Format messages.
  This version supports AMQP messages.
  """

  @behaviour :gen_event

  alias Backend.{AMQP, RabbitMQ}

  @impl true
  def init({__MODULE__, _name}) do
    if user = Process.whereis(:user) do
      Process.group_leader(self(), user)
      {:ok, RabbitMQ.init_conn()}
    else
      {:error, :ignore}
    end
  end

  @impl true
  def handle_call({:initialize, _options}, _state) do
    {:ok, :ok, RabbitMQ.init_conn()}
  end

  @impl true
  def handle_info(_msg, state) do
    {:ok, state}
  end

  @impl true
  def handle_event({level, _group_leader, {Logger, message, timestamp, metadata}}, channel) do
    AMQP.log_event(level, message, timestamp, metadata, channel)

    {:ok, channel}
  end
end
