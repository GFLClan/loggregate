defmodule LoggregateWeb.DashboardLive do
  use Phoenix.LiveView, layout: {LoggregateWeb.LayoutView, "live.html"}
  alias Loggregate.LogSearch

  def mount(_params, _assigns, socket) do
    socket = if connected?(socket) do
      case get_connect_params(socket) do
        %{"hash" => <<"#", hash::binary>>} ->
          {:ok, consumer} = Loggregate.LogReceiver.LiveViewConsumer.start_link(self())
          query = URI.decode(to_string(hash))
          predicate = LogSearch.build_search_predicate(query)
          {:ok, tag} = GenStage.sync_subscribe(consumer, to: Loggregate.LogReceiver.LogIngestBroadcaster, selector: predicate, cancel: :transient)

          assign(socket, consumer: consumer, subscription_tag: tag, filter: query)
        params ->
          IO.inspect(params)
          {:ok, consumer} = Loggregate.LogReceiver.LiveViewConsumer.start_link(self())
          {:ok, tag} = GenStage.sync_subscribe(consumer, to: Loggregate.LogReceiver.LogIngestBroadcaster, cancel: :transient)

          assign(socket, consumer: consumer, subscription_tag: tag, filter: "")
      end
    else
      assign(socket, filter: "")
    end

    {:ok, assign(socket, entries: [])}
  end

  def handle_info({:log_msg, log_msg}, socket) do
    {:noreply, update(socket, :entries, &([log_msg.log_data.line | &1] |> Enum.slice(0, 50)))}
  end

  def handle_event("update_filter", %{"query" => query}, %{assigns: %{consumer: consumer, subscription_tag: tag} = _assigns} = socket) do
    predicate = LogSearch.build_search_predicate(query)
    {:ok, tag} = GenStage.sync_resubscribe(consumer, tag, :normal, to: Loggregate.LogReceiver.LogIngestBroadcaster, selector: predicate, cancel: :transient)
    socket = assign(socket, entries: [], filter: query, subscription_tag: tag)

    {:noreply, socket}
  end

  def render(assigns) do
    Phoenix.View.render(LoggregateWeb.SearchView, "log_live.html", assigns)
  end

  def terminate(_reason, socket) do
    update(socket, :consumer, &(GenStage.stop(&1)))
  end
end
