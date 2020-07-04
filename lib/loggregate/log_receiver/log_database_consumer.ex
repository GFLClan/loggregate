defmodule Loggregate.LogReceiver.LogDatabaseConsumer do
  use GenStage
  alias Loggregate.{Repo, LogEntry}
  alias Loggregate.LogReceiver.ParsedLogEntry

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, nil, subscribe_to: [Loggregate.LogReceiver.LogDatabaseProducer]}
  end

  def handle_events(events, _from, state) do
    entries = Enum.map(events, fn %ParsedLogEntry{} = entry ->
      %{server_id: server_id, address: address, port: port, timestamp: timestamp, log_data: log_data} = entry

      ip_address = to_string(:inet_parse.ntoa(address))
      log_data = log_data
        |> Map.put_new(:server, server_id)
        |> Map.put_new(:address, "#{ip_address}:#{port}")

      %{timestamp: timestamp, log_data: log_data}
    end)
    Repo.insert_all(LogEntry, entries)

    {:noreply, [], state}
  end
end
