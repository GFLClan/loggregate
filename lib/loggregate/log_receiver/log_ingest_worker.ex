defmodule Loggregate.LogReceiver.LogIngestWorker do
  use GenStage
  alias Loggregate.{Repo, LogEntry}
  alias Loggregate.LogReceiver.LogParser

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, nil, subscribe_to: [Loggregate.LogReceiver.LogIngestProducer]}
  end

  def handle_events(events, _from, state) do
    entries = Enum.map(events, fn {data, address} ->
      log_msg_passwd(data, address)
    end)

    Repo.insert_all(LogEntry, entries)

    {:noreply, [], state}
  end

  def log_msg_passwd(data, {address, port}) do
    [password, message] = :binary.split(data, "L")
    {server_id, _} = Integer.parse(password)
    {timestamp, log_data} = LogParser.parse(message)
    ip_address = to_string(:inet_parse.ntoa(address))

    log_data = log_data
    |> Map.put_new(:server, server_id)
    |> Map.put_new(:address, "#{ip_address}:#{port}")

    %{timestamp: timestamp, log_data: log_data}
  end
end
