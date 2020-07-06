defmodule Loggregate.LogReceiver.Parsers.Say do
  @behaviour Loggregate.LogReceiver.Parser

  @say_regex ~r/^"(.+)<\d+><([\S]+)><\w+>" (?:say|say_team) "(.+)"$/
  def parse(message) do
    if Regex.match?(@say_regex, message) do
      [_, name, steamid, chat_message] = Regex.run(@say_regex, message)
      {:ok, %{line: message, type: :chat, message: chat_message, who: %{steamid: steamid, name: name}}}
    else
      :no_match
    end
  end
end
