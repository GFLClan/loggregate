defmodule Loggregate.LogReceiver.Parsers.Connected do
  @behaviour Loggregate.LogReceiver.Parser

  @connected_regex ~r/^"(.+)<\d+><([\S]+)><>" connected, address "([0-9.]+):([0-9]+)"$/
  def parse(message) do
    if Regex.match?(@connected_regex, message) do
      [_, name, steamid, address, port] = Regex.run(@connected_regex, message)
      loc = with {:ok, ipaddr} <- :inet.parse_address(to_charlist(address)),
                  {:ok, %{"latitude" => lat, "longitude" => lon} = _entry} <- :locus.lookup(:maxmind, ipaddr) do
        %{lat: lat, lon: lon}
      else
        _ -> nil
      end

      {:ok, %{line: message, type: :connected, who: %{steamid: steamid, name: name, name_kw: name, address: address, port: port, location: loc}}}
    else
      :no_match
    end
  end
end
