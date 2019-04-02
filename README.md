# GelfAmqpLogger

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gelf_amqp_logger` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gelf_amqp_logger, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir*lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/gelf_amqp_logger](https://hexdocs.pm/gelf_amqp_logger).

## Metrics

### Usage

* First, you need to have a Graylog instance up and running. In order to do that, you'll need to do the following:

* Install [Docker Toolbox](https://docs.docker.com/toolbox/).

* Then, you have to run the following command in the directory that the `graylog/docker-compose.yml` resides.

```bash
docker*compose up
```

* You also have to enable port-forwarding in your VM the following ports:

  * 9000:9000
  * 15672:15672
  * 15671:15671
  * 5671:5671
  * 5672:5672

* Add the dep in your `mix.exs` accordingly:

```elixir
defp deps() do
  [
    ...,
    {:gelf_amqp_logger, ariadne: "lib/gelf_amqp_logger"},
    ...
  ]
end
```

* Add to your `config.exs` the following logger configuration:

```elixir
# config/config.exs

config :logger,
  backends: [:console, {GelfAMQPHandler, :gelf_amqp_logger}],
  format: "\n$time [$level]$levelpad $metadata- $message\n",
  level: :debug,
  metadata: [:module],
  utc_log: true,
  colors: [enabled: true]

config :logger, :gelf_amqp_logger,
  bind_opts: [
    arguments: [],
    nowait: false,
    routing_key: ""
  ],
  connection_opts: [
    channel_max: 0,
    client_properties: [],
    connection_timeout: 60_000,
    frame_max: 0,
    heartbeat: 10,
    host: <VM IP>,
    port: 5672,
    ssl_options: :none,
    vhost: "/"
  ],
  exchange_name: <your exchange name>,
  exchange_opts: [
    auto_delete: false,
    durable: true,
    internal: false,
    passive: false,
    type: :direct
  ],
  queue_name: <your queue name>,
  queue_opts: [
    auto_delete: false,
    durable: true,
    exclusive: false,
    passive: false
  ]
  ```