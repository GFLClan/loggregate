defmodule Loggregate.ServerMapping do
  import Ecto.Query
  alias Loggregate.Repo
  alias Loggregate.ServerMapping.ServerMapping

  def list_servers() do
    Repo.all(ServerMapping)
  end

  def get_server(id) do
    Repo.get(ServerMapping, id)
  end

  def search_by_server_id(id) do
    Repo.one(from s in ServerMapping, where: s.server_id == ^id)
  end

  def search_by_server_name(name) do
    Repo.one(from s in ServerMapping, where: s.server_name == ^name)
  end

  def create_server_mapping(id, name) do
    %ServerMapping{}
    |> ServerMapping.changeset(%{server_id: id, server_name: name})
    |> Repo.insert()
  end
end
