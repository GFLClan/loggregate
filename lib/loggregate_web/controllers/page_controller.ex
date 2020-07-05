defmodule LoggregateWeb.PageController do
  use LoggregateWeb, :controller

  plug :put_layout, :false
  def index(conn, _params) do
    if conn.assigns[:user] do
      redirect(conn, to: Routes.search_path(conn, :index))
    else
      render(conn, "index.html")
    end
  end

  def do_logout(conn, %{"logout" => "true"}) do
    clear_session(conn) |>
      redirect(to: Routes.page_path(conn, :index))
  end
end
