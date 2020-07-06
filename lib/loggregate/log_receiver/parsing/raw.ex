defmodule Loggregate.LogReceiver.Parsers.Raw do
  alias Loggregate.LogReceiver.Parsers
  @behaviour Loggregate.LogReceiver.Parser

  def parse(message) do
    case Parsers.Who.parse(message) do
      {:ok, [name, steamid]} -> {:ok, %{line: message, type: :raw, who: %{steamid: steamid, name: name}}}
      _ -> {:ok, %{line: message, type: :raw}}
    end
  end
end
