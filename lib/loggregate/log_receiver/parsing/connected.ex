defmodule Loggregate.LogReceiver.Parsers.Connected do
  @behaviour Loggregate.LogReceiver.Parser

  require Logger

  @connected_regex ~r/^"(.+)<\d+><([\S]+)><>" connected, address "([0-9.]+):([0-9]+)"$/
  def parse(message) do
    if Regex.match?(@connected_regex, message) do
      [_, name, steamid, address, port] = Regex.run(@connected_regex, message)
      loc = case :locus.lookup(:maxmind, address) do
        {:ok, %{"latitude" => lat, "longitude" => lon}} = _entry -> %{lat: lat, lon: lon}
        err ->
          Logger.warn("Error getting location data #{inspect(err)}")

          nil
      end

      {:ok, %{line: message, type: :connected, who: %{steamid: steamid, name: name, name_kw: name, address: address, port: port, location: loc}}}
    else
      :no_match
    end
  end
end
