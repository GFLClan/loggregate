defmodule Loggregate.LogReceiver.LogIngestProducer do
  use GenStage

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:producer, {:queue.new, 0}}
  end

  def handle_demand(demand, {queue, pending_demand}) do
    dispatch_events(queue, demand + pending_demand, [])
  end

  def dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  def dispatch_events(queue, demand, events) do
    IO.puts("Dispatching events with #{demand} demand")
    case :queue.out(queue) do
      {{:value, entry}, queue} ->
        dispatch_events(queue, demand - 1, [entry | events])
      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end

  def handle_cast({:new_log, entry}, {queue, pending_demand}) do
    dispatch_events(:queue.in(entry, queue), pending_demand, [])
  end
end
