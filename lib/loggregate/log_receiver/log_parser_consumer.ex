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
    GenStage.cast(Loggregate.LogReceiver.LogIngestBroadcaster, {:parsed_entries, Enum.map(events, &(log_msg_passwd(&1)))})

    {:noreply, [], state}
  end

  def log_msg_passwd({data, {address, port}}) do
    [password, message] = :binary.split(data, "L")
    {server_id, _} = Integer.parse(password)
    {timestamp, log_data} = parse(message)

    %ParsedLogEntry{
      server_id: server_id,
      address: address,
      port: port,
      timestamp: timestamp,
      log_data: log_data
    }
  end

  def parse(line) do
    trimmed_line = String.slice(line, 0..-2) |> String.trim()
    [_, month, day, year, hour, minute, second, message] = Regex.run(~r/^(\d+)\/(\d+)\/(\d+)\s+-\s+(\d+):(\d+):(\d+):\s*(.*)$/, trimmed_line)
    [month, day, year, hour, minute, second] = Enum.map([month, day, year, hour, minute, second], fn i ->
      {int, _} = Integer.parse(i)
      int
    end)
    {:ok, timestamp} = NaiveDateTime.from_erl({{year, month, day}, {hour, minute, second}})
    {timestamp, parse_message(message)}
  end

  alias Loggregate.LogReceiver.Parsers
  @parsers [
    Parsers.Cvar,
    Parsers.Rcon,
    Parsers.Connected,
    Parsers.Say,
    Parsers.Raw
  ]



  def parse_message(message) do
    Enum.reduce(@parsers, :no_match, fn parser, acc ->
        case acc do
          :no_match ->
            case parser.parse(message) do
              :skip -> :skip
              :no_match -> :no_match
              {:ok, parsed} -> parsed
            end
          _ -> acc
        end
    end)
  end
end
