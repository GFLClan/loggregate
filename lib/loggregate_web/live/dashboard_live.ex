defmodule LoggregateWeb.DashboardLive do
  use Phoenix.LiveView, layout: {LoggregateWeb.LayoutView, "live.html"}

  def mount(_params, _assigns, socket) do
    socket = if connected?(socket) do
      {:ok, consumer} = Loggregate.LogReceiver.LiveViewConsumer.start_link(self())
      assign(socket, consumer: consumer)
    else
      socket
    end

    {:ok, assign(socket, entries: [], filter: "")}
  end

  def handle_info({:log_msg, log_msg}, socket) do
    {:noreply, update(socket, :entries, &([log_msg.log_data.line | &1] |> Enum.slice(0, 50)))}
  end

  def handle_event("update_filter", %{"query" => query}, socket) do
    {:noreply, assign(socket, :entries, []) |> assign(:filter, query)}
  end

  def render(assigns) do
    Phoenix.View.render(LoggregateWeb.SearchView, "log_live.html", assigns)
  end
end
