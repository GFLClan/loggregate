defmodule Loggregate.LogReceiver.Parsers.Who do
  @behaviour Loggregate.LogReceiver.Parser

  @who_regex ~r/"(.+)<\d+><([\S]+)><\w*>"/
  def parse(message) do
    if Regex.match?(@who_regex, message) do
      [_, name, steamid] = Regex.run(@who_regex, message)
      {:ok, %{steamid: steamid, name: name, name_kw: name}}
    else
      :no_match
    end
  end
end
