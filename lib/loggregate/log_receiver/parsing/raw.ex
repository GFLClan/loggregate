defmodule Loggregate.LogReceiver.Parsers.Raw do
  alias Loggregate.LogReceiver.Parsers
  @behaviour Loggregate.LogReceiver.Parser

  def parse(message) do
    case Parsers.Who.parse(message) do
      {:ok, who} -> {:ok, %{line: message, type: :raw, who: who}}
      _ -> {:ok, %{line: message, type: :raw}}
    end
  end
end
