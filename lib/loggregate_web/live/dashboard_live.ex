defmodule LoggregateWeb.DashboardLive do
  use Phoenix.LiveView, layout: {LoggregateWeb.LayoutView, "live.html"}
  alias Loggregate.LogSearch

  def mount(_params, _assigns, socket) do
    socket = if connected?(socket) do
      {:ok, consumer} = Loggregate.LogReceiver.LiveViewConsumer.start_link(self())
      {:ok, tag} = GenStage.sync_subscribe(consumer, to: Loggregate.LogReceiver.LogIngestBroadcaster, cancel: :transient)
      case get_connect_params(socket) do
        %{"hash" => <<"#", hash::binary>>} ->
          query = URI.decode(to_string(hash))
          predicate = LogSearch.build_search_predicate(query)

          assign(socket, consumer: consumer, subscription_tag: tag, filter: query, predicate: predicate)
        params ->
          IO.inspect(params)

          assign(socket, consumer: consumer, subscription_tag: tag, filter: "", predicate: fn _entry -> true end)
      end
    else
      assign(socket, filter: "", predicate: fn _entry -> true end)
    end

    {:ok, assign(socket, entries: [])}
  end

  def handle_info({:log_msg, log_msg}, %{assigns: %{predicate: predicate} = _assigns} = socket) do
    if predicate.(log_msg) do
      {:noreply, update(socket, :entries, &([log_msg.log_data.line | &1] |> Enum.slice(0, 50)))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_filter", %{"query" => query}, socket) do
    predicate = LogSearch.build_search_predicate(query)

    {:noreply, assign(socket, entries: [], filter: query, predicate: predicate)}
  end

  def render(assigns) do
    Phoenix.View.render(LoggregateWeb.SearchView, "log_live.html", assigns)
  end

  def terminate(_reason, socket) do
    update(socket, :consumer, &(GenStage.stop(&1)))
  end
end
