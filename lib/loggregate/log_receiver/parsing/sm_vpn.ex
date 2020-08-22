defmodule Loggregate.LogReceiver.Parsers.PluginVPN do
  @behaviour Loggregate.LogReceiver.Parser

  require Logger
  alias Loggregate.LogReceiver.Parser
  require Loggregate.LogReceiver.Parser

  @vpn ~r/^\[vpnchecker.smx\] \[VPN\] VPN Detected: <([\S]+)> <(.+)> <([0-9.]+)> \| (KICKED|ALLOWED)$/
  def parse(message) do
    if Regex.match?(@vpn, message) do
      [_, steamid, name, address, action] = Regex.run(@vpn, message)
      loc = Parser.lookup_location(address)

      {:ok, %{line: message, type: :vpn_detected, who: %{steamid: steamid, name: name, name_kw: name, address: address, location: loc}, vpn_action: action}}
    else
      :no_match
    end
  end
end
