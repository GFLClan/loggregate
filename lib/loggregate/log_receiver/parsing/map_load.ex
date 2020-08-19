defmodule Loggregate.LogReceiver.Parsers.MapLoad do
  @behaviour Loggregate.LogReceiver.Parser

  require Logger
  require Loggregate.LogReceiver.Parser

  @map_regex ~r/^Started map "(\S+)" \(CRC "([A-z0-9\-]+)"\)$/
  def parse(message) do
    if Regex.match?(@map_regex, message) do
      [_, map, crc] = Regex.run(@map_regex, message)

      {:ok, %{line: message, type: :map, map: map, map_crc: crc}}
    else
      :no_match
    end
  end
end
