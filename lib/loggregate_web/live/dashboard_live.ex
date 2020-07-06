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

    {:ok, assign(socket, entries: [], paused: false), temporary_assigns: [entries: []]}
  end

  def handle_info({:new_msgs, log_msgs}, %{assigns: %{predicate: predicate, paused: false} = _assigns} = socket) do
    matching_entries = Enum.filter(log_msgs, &(predicate.(&1))) |>
      Enum.map(fn entry ->
        hash = :crypto.hash(:md5, entry.log_data.line <> (entry.timestamp |> NaiveDateTime.to_string))

        %{hash: Base.encode16(hash), entry: entry}
      end)

    {:noreply, assign(socket, :entries, matching_entries)}
  end

  def handle_info({:new_msgs, _log_msgs}, %{assigns: %{paused: true} = _assigns} = socket) do
    {:noreply, socket}
  end

  def handle_event("update_filter", %{"query" => query}, socket) do
    predicate = LogSearch.build_search_predicate(query)

    {:noreply, assign(socket, filter: query, predicate: predicate)}
  end

  def handle_event("pause", _value, socket) do
    {:noreply, assign(socket, paused: true)}
  end

  def handle_event("unpause", _value, socket) do
    {:noreply, assign(socket, paused: false)}
  end

  def render(assigns) do
    Phoenix.View.render(LoggregateWeb.SearchView, "log_live.html", assigns)
  end

  def terminate(_reason, socket) do
    update(socket, :consumer, &(GenStage.stop(&1)))
  end
end
