defmodule Loggregate.Permissions do
  alias Loggregate.Accounts.User
  alias Loggregate.ServerMapping.ServerMapping
  alias Loggregate.Indices.Index
  alias Loggregate.Indices

  def user_can_search(%User{admin: true} = _user, _) do
    true
  end
  def user_can_search(%User{} = user, %ServerMapping{} = server) do
    Enum.any?(user.servers, &(&1.server_id == server.server_id))
  end

  def user_can_search(%User{} = user, %Index{} = index) do
    cond do
      Enum.any?(user.indices, &(&1.name == index.name)) -> true
      Enum.any?(user.parent_indicies, &(&1.name == index.name)) -> true
      true -> false
    end
  end

  def user_can_search(_, _), do: false

  def get_search_indexes(%User{} = user) do
    Indices.list_indices() |> Enum.filter(&(user_can_search(user, &1)))
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
