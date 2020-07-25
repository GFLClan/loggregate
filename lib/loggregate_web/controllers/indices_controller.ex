defmodule LoggregateWeb.IndicesController do
  use LoggregateWeb, :controller
  alias Loggregate.{Repo, Indices, Permissions, ServerMapping}
  alias Loggregate.ServerMapping.ServerMapping, as: Server
  alias Loggregate.Accounts.User
  require Loggregate.Permissions

  def indices(conn, _params) do
    indices = Permissions.get_managed_indices(conn.assigns[:user])
    render(conn, "indices.html", indices: indices, settings: :indices)
  end

  def index_users(conn, %{"id" => index_id, "user" => user_id}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        Permissions.user_has_permission(conn, index, :manage) do
          case Enum.filter(index.managed_users, &(to_string(&1.id) == user_id)) do
            [user] ->
              changeset = User.changeset(user, %{})
              render(conn, "user.html", index: index, target_user: user, changeset: changeset, settings: :index_settings, index_settings: :users)
            _ -> render(conn, "index_users.html", index: index, settings: :index_settings, index_settings: :users)
          end
        end
    end
  end

  def index_users(conn, %{"id" => index_id}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        Permissions.user_has_permission(conn, index, :manage) do
          render(conn, "index_users.html", index: index, settings: :index_settings, index_settings: :users)
        end
    end
  end

  def new_user(conn, %{"id" => index_id}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        Permissions.user_has_permission(conn, index, :manage) do
          changeset = User.changeset(%User{}, %{})
          render(conn, "new_user.html", index: index, changeset: changeset, settings: :index_settings, index_settings: :users)
        end
    end
  end

  def create_user(conn, %{"id" => index_id, "user" => new_user}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        case Loggregate.Accounts.create_user(new_user |> Map.put_new("admin", false)) do
          {:ok, user} ->
            {:ok, _} = Loggregate.Accounts.create_acl_entry(%{target_user_id: user.steamid, index_id: index.id, user_access: "manage"})
            if new_user["index_admin"] == "true" do
              {:ok, _} = Loggregate.Accounts.create_acl_entry(%{user_id: user.steamid, index_id: index.id, index_access: "manage"})
            end
            redirect(conn, to: Routes.indices_path(conn, :index_users, index, user: user.id))
          {:error, %Ecto.Changeset{} = changeset} ->
            IO.inspect(changeset)
            render(conn, "new_user.html", index: index, changeset: changeset, settings: :index_settings, index_settings: :users)
        end
    end
  end

  def index_servers(conn, %{"id" => index_id, "server" => server_id}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        Permissions.user_has_permission(conn, index, :manage) do
          case Enum.filter(index.servers, &(to_string(&1.id) == server_id)) do
            [server] ->
              changeset = Server.changeset(server, %{})
              render(conn, "server.html", index: index, changeset: changeset, settings: :index_settings, index_settings: :servers)
            _ -> render(conn, "index_servers.html", index: index, settings: :index_settings, index_settings: :users)
          end
        end
    end
  end

  def index_servers(conn, %{"id" => index_id}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        Permissions.user_has_permission(conn, index, :manage) do
          render(conn, "index_servers.html", index: index, settings: :index_settings, index_settings: :servers)
        end
    end
  end

  def new_server(conn, %{"id" => index_id}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        Permissions.user_has_permission(conn, index, :manage) do
          changeset = Server.changeset(%Server{}, %{server_id: :crypto.rand_uniform(0, 999999)})
          render(conn, "new_server.html", index: index, changeset: changeset, settings: :index_settings, index_settings: :servers)
        end
    end
  end

  def create_server(conn, %{"id" => index_id, "server_mapping" => server}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        Permissions.user_has_permission(conn, index, :manage) do
          changeset = Server.changeset(%Server{}, server |> Map.put_new("index_id", index.id))
          {:ok, server} = Repo.insert(changeset)
          redirect(conn, to: Routes.indices_path(conn, :index_servers, index, server: server.id))
        end
    end
  end

  def update_server(conn, %{"id" => index_id, "server" => server_id, "server_mapping" => server}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        Permissions.user_has_permission(conn, index, :manage) do
          case ServerMapping.get_server(server_id) do
            nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
            old_server ->
              Permissions.user_has_permission(conn, old_server, :manage) do
                changeset = Server.changeset(old_server, server)
                {:ok, server} = Repo.update(changeset)

                changeset = Server.changeset(server, %{})
                render(conn, "server.html", index: index, changeset: changeset, settings: :index_settings, index_settings: :servers)
              end
          end
        end
    end
  end

  def delete_server(conn, %{"id" => index_id, "server" => server_id}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        Permissions.user_has_permission(conn, index, :manage) do
          case Enum.filter(index.servers, &(to_string(&1.id) == server_id)) do
            [server] ->
              Repo.delete!(server)
              redirect(conn, to: Routes.indices_path(conn, :index_servers, index))
            _ -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
          end
        end
    end
  end

  def refresh_server_token(conn, %{"id" => index_id, "server" => server_id}) do
    case Indices.get_index(index_id) do
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
      index ->
        Permissions.user_has_permission(conn, index, :manage) do
          case Enum.filter(index.servers, &(to_string(&1.id) == server_id)) do
            [server] ->
              changeset = Server.changeset(server, %{server_id: :crypto.rand_uniform(0, 999999)})
              Repo.update!(changeset)

              redirect(conn, to: Routes.indices_path(conn, :index_servers, index, server: server.id))
            _ -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
          end
        end
    end
  end
end
