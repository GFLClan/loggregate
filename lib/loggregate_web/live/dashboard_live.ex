defmodule LoggregateWeb.DashboardLive do
  use Phoenix.LiveView, layout: {LoggregateWeb.LayoutView, "live.html"}

  def mount(_params, _assigns, socket) do
    if connected?(socket), do: :timer.send_interval(3000, :update)
    {:ok, assign(socket, entries: ["Hello world"])}
  end

  def handle_info(:update, socket) do
    {:noreply, update(socket, :entries, &(["Hello 2" | &1] |> Enum.slice(0, 50)))}
  end

  def render(assigns) do
    Phoenix.View.render(LoggregateWeb.SearchView, "log_live.html", assigns)
  end
end
