defmodule Loggregate.Grok.ConfigCache do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def init(_opts) do
    :ets.new(:loggregate_grok_config, [:named_table])
    Loggregate.Grok.reload_config_cache()

    {:ok, nil}
  end
end
