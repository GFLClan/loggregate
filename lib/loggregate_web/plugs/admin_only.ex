defmodule LoggregateWeb.Plugs.AdminOnly do
  use LoggregateWeb, :controller
  alias Loggregate.Accounts

  def init(_params) do

  end

  def call(conn, _params) do
    with %{user: user} <- conn.assigns,
         %Accounts.User{admin: true} <- user
    do
      conn
    else
      nil ->
        conn
          |> put_flash(:info, "You must be logged in.")
          |> put_status(302)
          |> redirect(to: Routes.page_path(conn, :index))
      %Accounts.User{admin: false} ->
        conn
          |> put_status(403)
          |> put_view(LoggregateWeb.ErrorView)
          |> render(:"403")
    end
  end
end
