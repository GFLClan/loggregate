defmodule Loggregate.LogReceiver.Parser do
  @callback parse(String.t) :: {:ok, term()} | :no_match | :skip
end
