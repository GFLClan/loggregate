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
    Repo.all(from s in ServerMapping, where: s.server_id in ^ids)
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

  alias Loggregate.ServerMapping.UserAccess

  @doc """
  Returns the list of server_access.

  ## Examples

      iex> list_server_access()
      [%UserAccess{}, ...]

  """
  def list_server_access do
    Repo.all(UserAccess)
  end

  @doc """
  Gets a single user_access.

  Raises `Ecto.NoResultsError` if the User access does not exist.

  ## Examples

      iex> get_user_access!(123)
      %UserAccess{}

      iex> get_user_access!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_access!(id), do: Repo.get!(UserAccess, id)

  @doc """
  Creates a user_access.

  ## Examples

      iex> create_user_access(%{field: value})
      {:ok, %UserAccess{}}

      iex> create_user_access(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_access(attrs \\ %{}) do
    %UserAccess{}
    |> UserAccess.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_access.

  ## Examples

      iex> update_user_access(user_access, %{field: new_value})
      {:ok, %UserAccess{}}

      iex> update_user_access(user_access, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_access(%UserAccess{} = user_access, attrs) do
    user_access
    |> UserAccess.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_access.

  ## Examples

      iex> delete_user_access(user_access)
      {:ok, %UserAccess{}}

      iex> delete_user_access(user_access)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_access(%UserAccess{} = user_access) do
    Repo.delete(user_access)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_access changes.

  ## Examples

      iex> change_user_access(user_access)
      %Ecto.Changeset{data: %UserAccess{}}

  """
  def change_user_access(%UserAccess{} = user_access, attrs \\ %{}) do
    UserAccess.changeset(user_access, attrs)
  end
end
