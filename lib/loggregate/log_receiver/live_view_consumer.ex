defmodule Loggregate.LogReceiver.LiveViewConsumer do
  use GenStage

  def start_link(parent) do
    GenStage.start_link(__MODULE__, parent)
  end

  def init(parent) do
    {:consumer, parent}
  end

  def handle_events(events, _from, parent) do
    send(parent, {:new_msgs, events})
    {:noreply, [], parent}
  end
end
