defmodule Loggregate.LogReceiver.Parser do
  @callback parse(String.t) :: {:ok, term()} | :no_match | :skip

  defmacro lookup_location(address) do
    quote do
      case :locus.lookup(:maxmind, unquote(address)) do
        {:ok, %{"location" => %{"latitude" => lat, "longitude" => lon}}} -> %{lat: lat, lon: lon}
        err ->
          Logger.warn("Error getting location data #{inspect(err)}")

          nil
      end
    end
  end
end
