defmodule Loggregate.LogReceiver.LogDatabaseProducer do
  use GenStage

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:producer_consumer, nil, subscribe_to: [Loggregate.LogReceiver.LogIngestBroadcaster]}
  end

  def handle_events(events, _from, state) do
    {:noreply, events, state}
  end
end
