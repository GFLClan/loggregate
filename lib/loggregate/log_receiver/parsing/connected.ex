defmodule Loggregate.LogReceiver.Parsers.Connected do
  @behaviour Loggregate.LogReceiver.Parser

  require Logger
  require Loggregate.LogReceiver.Parser
  alias Loggregate.LogReceiver.Parser

  @connected_regex ~r/^"(.+)<\d+><([\S]+)><>" connected, address "([0-9.]+):([0-9]+)"$/
  @connect_plugin_regex ~r/^\[logconnections.smx\] [0-9:]+ - <(.+)> <([\S]+)> <([0-9.]+)> CONNECTED from <.*>$/
  def parse(message) do
    cond do
      Regex.match?(@connected_regex, message) ->
        [_, name, steamid, address, port] = Regex.run(@connected_regex, message)
        loc = Parser.lookup_location(address)

        {:ok, %{line: message, type: :connected, who: %{steamid: steamid, name: name, name_kw: name, address: address, port: port, location: loc}}}
      Regex.match?(@connect_plugin_regex, message) ->
        [_, name, steamid, address] = Regex.run(@connect_plugin_regex, message)
        loc = Parser.lookup_location(address)

        {:ok, %{line: message, type: :connected, who: %{steamid: steamid, name: name, name_kw: name, address: address, port: 0, location: loc}}}
      true ->
        :no_match
    end
  end
end
