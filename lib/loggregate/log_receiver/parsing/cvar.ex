defmodule Loggregate.LogReceiver.Parsers.Cvar do
  @behaviour Loggregate.LogReceiver.Parser

  @cvar_regex ~r/^"(\w+)\" = \"(\w+)"$/
  @server_cvar_regex ~r/^server_cvar: "(\w+)" "(\w+)"$/
  def parse(message) do
    cond do
      Regex.match?(@cvar_regex, message) ->
        [_, cvar, value] = Regex.run(@cvar_regex, message)
        {:ok, %{line: message, type: :cvar, cvar: %{name: cvar, value: value}}}
      Regex.match?(@server_cvar_regex, message) ->
        [_, cvar, value] = Regex.run(@server_cvar_regex, message)
        {:ok, %{line: message, type: :cvar, cvar: %{name: cvar, value: value}}}
      true -> :no_match
    end
  end
end
