defmodule Loggregate.ServerMapping do
  import Ecto.Query
  alias Loggregate.Repo
  alias Loggregate.ServerMapping.ServerMapping

  def list_servers() do
    Repo.all(from s in ServerMapping, preload: [:index])
  end

  def get_server(id) do
    Repo.get(ServerMapping, id)
  end

  def search_by_server_id(id) do
    Repo.one(from s in ServerMapping, where: s.server_id == ^id)
  end

  def search_by_server_ids(ids) do
    Repo.all(from s in ServerMapping, where: s.server_id in ^ids, preload: [:index])
  end

  def search_by_server_name(name) do
    Repo.one(from s in ServerMapping, where: s.server_name == ^name)
  end

  def create_server_mapping(attrs) do
    %ServerMapping{}
    |> ServerMapping.changeset(attrs)
    |> Repo.insert()
  end

  def update_server_mapping(%ServerMapping{} = server, attrs) do
    server
    |> ServerMapping.changeset(attrs)
    |> Repo.update()
  end

  def delete_server_mapping(mapping) do
    Repo.delete(mapping)
  end
end
