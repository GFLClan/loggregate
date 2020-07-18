defmodule Loggregate.LogReceiver.Parsers.Rcon do
  @behaviour Loggregate.LogReceiver.Parser

  require Logger
  require Loggregate.LogReceiver.Parser
  alias Loggregate.LogReceiver.Parser

  @rcon_regex ~r/^rcon from "((?:[0-9]{1,3}\.){3}[0-9]{1,3}):([0-9]{1,5})": command "(.*)"$/
  def parse(message) do
    if Regex.match?(@rcon_regex, message) do
      [_, address, port, command] = Regex.run(@rcon_regex, message)
      loc = Parser.lookup_location(address)

      {:ok, %{line: message, type: :rcon, command: command, from_addr: %{address: address, port: port, location: loc}}}
    else
      :no_match
    end
  end
end
