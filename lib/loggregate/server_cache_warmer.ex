defmodule Loggregate.ServerCacheWarmer do
  use Cachex.Warmer
  alias Loggregate.ServerMapping

  def interval, do: :timer.minutes(5)

  def execute(_state) do
    {:ok, ServerMapping.list_servers()}
  end
end
