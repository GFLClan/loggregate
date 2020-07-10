defmodule Loggregate.Permissions do
  alias Loggregate.Accounts.User
  alias Loggregate.ServerMapping.ServerMapping
  alias Loggregate.ServerMapping, as: Servers
  alias Loggregate.Indices.Index
  alias Loggregate.Indices
  alias Loggregate.LogReceiver.ParsedLogEntry

  def user_can_search(%User{admin: true} = _user, _) do
    true
  end
  def user_can_search(%User{} = user, %ServerMapping{} = server) do
    cond do
      Enum.any?(user.indices, &(&1.name == server.index.name)) -> true
      Enum.any?(user.servers, &(&1.server_id == server.server_id)) -> true
      true -> false
    end
  end

  def user_can_search(%User{} = user, %Index{} = index) do
    cond do
      Enum.any?(user.indices, &(&1.name == index.name)) -> true
      Enum.any?(user.parent_indices, &(&1.name == index.name)) -> true
      true -> false
    end
  end

  def user_can_search(_, _), do: false

  def get_search_indexes(%User{} = user) do
    Indices.list_indices() |> Enum.filter(&(user_can_search(user, &1)))
  end

  def get_search_servers(%User{} = user) do
    Servers.list_servers() |> Enum.filter(&(user_can_search(user, &1)))
  end

  def get_es_permissions_filter(%User{admin: true} = _user) do
    []
  end

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

  def user_can_manage(%User{admin: true} = _user, _) do
    true
  end

  def user_can_manage(%User{} = user, %Index{} = index) do
    cond do
      user.admin -> true
      Enum.any?(user.indices, &(&1.name == index.name)) -> true
      true -> false
    end
  end

  def user_can_manage(_, _), do: false
end
