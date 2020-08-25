defmodule Loggregate.LogReceiver.LogParserConsumer do
  use GenStage

  alias Loggregate.LogReceiver.ParsedLogEntry

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, nil, subscribe_to: [Loggregate.LogReceiver.LogIngestProducer]}
  end

  def handle_events(events, _from, state) do
    parsed_events = Enum.map(events, &(log_msg_passwd(&1))) |> Enum.filter(&(&1 !== :error))
    GenStage.cast(Loggregate.LogReceiver.LogIngestBroadcaster, {:parsed_entries, parsed_events})

    {:noreply, [], state}
  end

  def log_msg_passwd({data, {address, port}}) do
    [password, message] = :binary.split(data, "L")
    {server_id, _} = Integer.parse(password)
    case parse(message) do
      {timestamp, log_data} ->
        %ParsedLogEntry{
          server_id: server_id,
          address: address,
          port: port,
          timestamp: timestamp,
          log_data: transform_log_data(log_data)
        }
      _ -> :error
    end
  end

  def parse(line) do
    trimmed_line = String.slice(line, 0..-2) |> String.trim()
    with [_, month, day, year, hour, minute, second, message] <- Regex.run(~r/^(\d+)\/(\d+)\/(\d+)\s+-\s+(\d+):(\d+):(\d+):\s*(.*)$/, trimmed_line),
      [month, day, year, hour, minute, second] <- Enum.map([month, day, year, hour, minute, second], fn i ->
        {int, _} = Integer.parse(i)
        int
      end),
      {:ok, timestamp} <- NaiveDateTime.from_erl({{year, month, day}, {hour, minute, second}})
    do
      {timestamp, parse_message(message)}
    else
      _ -> :error
    end
  end

  def parse_message(message) do
    parsed = Enum.reduce(Loggregate.Grok.fetch_patterns(), :no_match, fn predicate, acc ->
        case acc do
          :no_match -> predicate.(message)
          _ -> acc
        end
    end)
    case parsed do
      :no_match -> %{type: :raw, line: message}
      named_matches ->
        entries = Map.put(named_matches, "line", message)
          |> Map.to_list()
          |> Enum.map(fn {key, value} ->
            {Map.get(Loggregate.Grok.fetch_aliases(), key, key), value}
          end)

        Map.new(entries)
    end
  end

  def lookup_location(address) do
    case :locus.lookup(:maxmind, address) do
      {:ok, %{"location" => %{"latitude" => lat, "longitude" => lon}}} -> %{"lat" => lat, "lon" => lon}
      err -> nil
    end
  end

  # TODO: Cleaner way to handle this
  def transform_log_data(log_data) do
    log_data = case Map.get(log_data, "who.address") do
      nil -> log_data
      address ->
        case lookup_location(address) do
          {:ok, loc} -> Map.put(log_data, "who.location", loc)
          _ -> log_data
        end
    end
    case Map.get(log_data, "from_addr.address") do
      nil -> log_data
      address ->
        case lookup_location(address) do
          {:ok, loc} -> Map.put(log_data, "from_addr.location", loc)
          _ -> log_data
        end
    end
  end
end
