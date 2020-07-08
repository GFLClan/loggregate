defmodule Loggregate.LogReceiver.LogDatabaseConsumer do
  use GenStage
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

      log_data
        |> Map.put_new(:server, server_id)
        |> Map.put_new(:address, ip_address)
        |> Map.put_new(:port, port)
        |> Map.put_new(:server_time, timestamp)
        |> Map.put_new(:timestamp, NaiveDateTime.utc_now())
    end)
    Loggregate.ElasticSearch.insert!(entries)

    {:noreply, [], state}
  end
end
