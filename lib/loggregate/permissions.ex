defmodule Loggregate.Permissions do
  alias Loggregate.Accounts.User
  alias Loggregate.ServerMapping.ServerMapping
  alias Loggregate.ServerMapping, as: Servers
  alias Loggregate.{Indices, Accounts}
  alias Loggregate.Indices.Index
  alias Loggregate.LogReceiver.ParsedLogEntry

  defmacro user_has_permission(conn, resource, permission, body) do
    quote location: :keep do
      import Loggregate.Permissions, only: [user_can_manage: 2]
      user = unquote(conn).assigns[:user]
      case unquote(permission) do
        :manage ->
          if user_can_manage(user, unquote(resource)) do
            unquote(body[:do])
          else
            raise Loggregate.PermissionError
          end
      end
    end
  end

  defmacro is_admin?(conn, body) do
    quote location: :keep do
      case unquote(conn) do
        %{assigns: %{user: %User{admin: true}}} -> unquote(body[:do])
        _ -> raise Loggregate.PermissionError
      end
    end
  end

  def user_can_search(%User{admin: true} = _user, _), do: true

  def user_can_search(%User{} = user, %ServerMapping{} = server) do
    cond do
      Enum.any?(user.acl, &(&1.index_id == server.index_id)) -> true
      Enum.any?(user.acl, &(&1.server_id == server.server_id)) -> true
      true -> false
    end
  end

  def user_can_search(%User{} = user, %Index{} = index) do
    Enum.any?(user.acl, &(&1.index_id == index.id))
  end

  def user_can_search(_, _), do: false

  def user_can_manage(%User{admin: true} = _user, _), do: true

  def user_can_manage(%User{} = user, %Index{} = index) do
    Enum.any?(user.acl, &(&1.index_id == index.id and &1.index_access == "manage"))
  end

  def user_can_manage(%User{} = user, %ServerMapping{} = server) do
    Enum.any?(user.acl, &(&1.server_id == server.server_id and &1.server_access == "manage"))
  end

  def user_can_manage(_, _), do: false

  def get_search_indices(%User{} = user) do
    Indices.list_indices() |> Enum.filter(&(user_can_search(user, &1)))
  end

  def get_search_servers(%User{} = user) do
    Servers.list_servers() |> Enum.filter(&(user_can_search(user, &1)))
  end

  def get_managed_users(%User{admin: true} = _user) do
    Accounts.list_users()
  end

  def get_managed_users(%User{} = user) do
    direct_users = Enum.filter(user.acl, &(&1.user_access == "manage")) |> Enum.map(&(&1.target_user))
    index_users = Enum.filter(user.acl, &(&1.index_access == "manage")) |> Enum.flat_map(&(&1.managed_users))

    direct_users ++ index_users
  end

  def get_managed_servers(%User{admin: true} = _user) do
    Servers.list_servers()
  end

  def get_managed_servers(%User{} = user) do
    direct_servers = Enum.filter(user.acl, &(&1.server_access == "manage")) |> Enum.map(&(&1.server))
    index_servers = Enum.filter(user.acl, &(&1.index_access == "manage")) |> Enum.flat_map(&(&1.servers))

    direct_servers ++ index_servers
  end

  def get_managed_indices(%User{admin: true} = _user) do
    Indices.list_indices()
  end

  def get_managed_indices(%User{} = user) do
    Enum.filter(user.acl, &(&1.index_access == "manage")) |> Enum.map(&(&1.index))
  end

  def get_es_permissions_filter(%User{admin: true} = _user), do: []

  def get_es_permissions_filter(%User{} = user) do
    servers = get_search_servers(user)
    [%{bool: %{should: Enum.map(servers, &(%{term: %{server: &1.server_id}}))}}]
  end

  def get_permissions_predicate(%User{} = user) do
    fn %ParsedLogEntry{} = entry ->
      cond do
        user.admin -> true
        Enum.any?(user.indices, &(&1.name == entry.index)) -> true
        Enum.any?(user.server, &(&1.server_id == entry.server_id)) -> true
        true -> false
      end
    end
  end

  def has_settings?(%User{admin: true} = _user), do: true

  def has_settings?(%User{} = user) do
    Enum.any?(user.acl, &(&1.server_access == "manage" or &1.index_access == "manage"))
  end

  def has_settings?(_user), do: false

  def sanitize_changeset(%Ecto.Changeset{} = changeset, %{assigns: %{user: %{admin: true} = _user}} = _conn), do: changeset

  def sanitize_changeset(%Ecto.Changeset{} = changeset, %{assigns: %{user: _user}} = _conn) do
    Ecto.Changeset.delete_change(changeset, :admin)
  end
end
