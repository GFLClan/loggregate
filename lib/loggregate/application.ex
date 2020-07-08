defmodule Loggregate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # TODO: Move this to a manager process
    Loggregate.ElasticSearch.create_index!()
    Loggregate.ElasticSearch.update_settings!()

    import Supervisor.Spec

    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Loggregate.Repo,
      # Start the endpoint when the application starts
      LoggregateWeb.Endpoint,
      # Starts a worker by calling: Loggregate.Worker.start_link(arg)
      # {Loggregate.Worker, arg},
      {Loggregate.LogReceiver.UdpListener, 26015},
      {Loggregate.LogReceiver.LogIngestProducer, []},
      {Loggregate.LogReceiver.LogIngestBroadcaster, []},
      {Loggregate.LogReceiver.LogDatabaseProducer, []},
      {Phoenix.PubSub, [name: Loggregate.PubSub, adapter: Phoenix.PubSub.PG2]}
    ]

    children = children ++ for i <- 1..System.schedulers_online, do: worker(Loggregate.LogReceiver.LogDatabaseConsumer, [], id: "db-worker-#{i}")
    children = children ++ for i <- 1..System.schedulers_online, do: worker(Loggregate.LogReceiver.LogParserConsumer, [], id: "parser-#{i}")
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Loggregate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LoggregateWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
