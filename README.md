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

## Usage

* First, you need to have a Graylog instance up and running. In order to do that, you'll need to do the following:

* Install [Docker Toolbox](https://docs.docker.com/toolbox/).

* Stop your docker machine in order to adjust the memory to 4096 MB, and start it again:

```bash
docker-machine stop
```

```bash
docker-machine start
```

* You also have to enable port-forwarding in your VM the following ports:

  * 9000:9000
  * 15672:15672
  * 15671:15671
  * 5671:5671
  * 5672:5672

* Then, you have to run the following command in the directory that the `graylog/docker-compose.yml` resides.

```bash
docker-compose up
```

* Now, considering that everything went well, you should have a Graylog instance in `localhost:9000` if you didn't tinker with the `docker-compose.yml`. The username and password are both `admin` by default.

Furthermore, you have to set up an input so that you will see you application logs in Graylog. To do that, you click on `System -> Inputs` and at `Select Input` you choose `GELF AMQP` and `Launch New Input`. Then, you choose the title of your input, select the node that is available, input the IP that your VM has already set up and fill up accordingly the queue name, exchange name and routing key that is the same as in your `config.exs`. Also, the usename and password must be the same as in your `.secrets.exs` file. Then, you click `Save` and  `Show received messages` and enable auto-updating.

* Add the dep in your `mix.exs` accordingly:

```elixir
defp deps() do
  [
    ...,
    {:gelf_amqp_logger, github: "dennisxtria/gelf_amqp_logger"},
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

Also, add the following secrets for your RabbitMQ instance:

```elixir
config :logger, :gelf_amqp_logger,
  username: <your username>,
  password: <your password>
```
