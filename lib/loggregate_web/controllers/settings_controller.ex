defmodule LoggregateWeb.SettingsController do
  use LoggregateWeb, :controller
  alias Loggregate.Accounts
  alias Loggregate.ServerMapping
  alias Loggregate.Indices

  def users(conn, _params) do
    users = Accounts.list_users()
    render(conn, "users.html", users: users, settings: :users)
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
      render(conn, "server.html", changeset: ServerMapping.ServerMapping.changeset(server, %{}), settings: :servers)
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def save_server(conn, %{"id" => id, "server_mapping" => target_server}) do
    with server when not is_nil(server) <- ServerMapping.get_server(id) do
      case ServerMapping.update_server_mapping(server, target_server) do
        {:ok, _user} ->
          redirect(conn, to: Routes.settings_path(conn, :servers))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "server.html", changeset: changeset, settings: :servers)
      end
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def refresh_server_token(conn, %{"id" => id}) do
    with server when not is_nil(server) <- ServerMapping.get_server(id) do
      <<new_id::unsigned-24>> = :crypto.strong_rand_bytes(3)
      {:ok, _} = ServerMapping.update_server_mapping(server, %{server_id: new_id})
      redirect(conn, to: Routes.settings_path(conn, :server, server))
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def new_server(conn, _params) do
    <<server_id::unsigned-24>> = :crypto.strong_rand_bytes(3)
    changeset = %ServerMapping.ServerMapping{} |> ServerMapping.ServerMapping.changeset(%{server_id: server_id})
    render(conn, "new_server.html", changeset: changeset, indices: Indices.list_indices(), settings: :servers)
  end

  def create_server(conn, %{"server_mapping" => server}) do
    case ServerMapping.create_server_mapping(server) do
      {:ok, server} ->
        server = Loggregate.Repo.preload(server, :index)
        Cachex.put(:ingest_server_cache, server.server_id, server.index)

        redirect(conn, to: Routes.settings_path(conn, :server, server))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_server.html", changeset: changeset, settings: :servers)
    end
  end

  def delete_server(conn, %{"id" => id}) do
    with server when not is_nil(server) <- ServerMapping.get_server(id) do
      case ServerMapping.delete_server_mapping(server) do
        {:ok, _user} ->
          redirect(conn, to: Routes.settings_path(conn, :servers))
        {:error, _err} ->
          put_status(conn, 500) |> put_view(LoggregateWeb.ErrorView) |> render(:"500")
      end
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end
end
