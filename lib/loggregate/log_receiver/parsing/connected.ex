defmodule Loggregate.LogReceiver.Parsers.Connected do
  @behaviour Loggregate.LogReceiver.Parser

  @connected_regex ~r/^"(.+)<\d+><([\S]+)><>" connected, address "([0-9.]+):([0-9]+)"$/
  def parse(message) do
    if Regex.match?(@connected_regex, message) do
      [_, name, steamid, address, port] = Regex.run(@connected_regex, message)
      {:ok, %{line: message, type: :connected, who: %{steamid: steamid, name: name, address: address, port: port}}}
    else
      :no_match
    end
  end
end
