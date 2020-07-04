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

  @cvar_regex ~r/^"(\w+)\" = \"(\w+)"$/
  @server_cvar_regex ~r/^server_cvar: "(\w+)" "(\w+)"$/
  @say_regex ~r/^"(.+)<\d+><([\S]+)><\w+>" (?:say|say_team) "(.+)"$/
  @connected_regex ~r/^"(.+)<\d+><([\S]+)><>" connected, address "([0-9.]+):([0-9]+)"$/
  def parse_message(message) do
    cond do
      Regex.match?(@cvar_regex, message) ->
        [_, cvar, value] = Regex.run(@cvar_regex, message)
        %{line: message, type: :cvar, cvar: %{name: cvar, value: value}}
      Regex.match?(@server_cvar_regex, message) ->
        [_, cvar, value] = Regex.run(@server_cvar_regex, message)
        %{line: message, type: :cvar, cvar: %{name: cvar, value: value}}
      Regex.match?(@say_regex, message) ->
        [_, name, steamid, chat_message] = Regex.run(@say_regex, message)
        %{line: message, type: :chat, message: chat_message, who: %{steamid: steamid, name: name}}
      Regex.match?(@connected_regex, message) ->
          [_, name, steamid, address, port] = Regex.run(@connected_regex, message)
          %{line: message, type: :connected, who: %{steamid: steamid, name: name, address: address, port: port}}
      true ->
        %{line: message, type: :raw}
    end
  end
end
