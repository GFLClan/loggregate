defmodule LoggregateWeb.SettingsController do
  use LoggregateWeb, :controller
  alias Loggregate.Accounts
  alias Loggregate.ServerMapping

  def users(conn, _params) do
    users = Accounts.list_users()
    render(conn, "users.html", users: users, settings: :users)
  end

  def new_user(conn, _params) do
    changeset = %Accounts.User{} |> Accounts.User.changeset(%{})
    render(conn, "new_user.html", changeset: changeset, settings: :users)
  end

  def create_user(conn, %{"user" => new_user}) do
    case Accounts.create_user(new_user) do
      {:ok, user} ->
        redirect(conn, to: Routes.settings_path(conn, :user, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_user.html", changeset: changeset, settings: :users)
    end
  end

  def user(conn, %{"id" => id}) do
    with user when not is_nil(user) <- Accounts.get_user(id) do
      render(conn, "user.html", changeset: Accounts.User.changeset(user, %{}), settings: :users)
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def save_user(conn, %{"id" => id, "user" => target_user}) do
    with user when not is_nil(user) <- Accounts.get_user(id) do
      case Accounts.update_user(user, target_user) do
        {:ok, _user} ->
          redirect(conn, to: Routes.settings_path(conn, :users))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "user.html", changeset: changeset, settings: :users)
      end
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def delete_user(conn, %{"id" => id}) do
    with user when not is_nil(user) <- Accounts.get_user(id) do
      case Accounts.delete_user(user) do
        {:ok, _user} ->
          redirect(conn, to: Routes.settings_path(conn, :users))
        {:error, _err} ->
          put_status(conn, 500) |> put_view(LoggregateWeb.ErrorView) |> render(:"500")
      end
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def servers(conn, _params) do
    servers = ServerMapping.list_servers()
    render(conn, "servers.html", servers: servers, settings: :servers)
  end

  def server(conn, %{"id" => id}) do
    with server when not is_nil(server) <- ServerMapping.get_server(id) do
      render(conn, "server.html", server: server, settings: :servers)
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end
end
