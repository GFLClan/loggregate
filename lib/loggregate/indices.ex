defmodule Loggregate.Indices do
  @moduledoc """
  The Indices context.
  """

  import Ecto.Query, warn: false
  alias Loggregate.Repo

  alias Loggregate.Indices.Index

  @doc """
  Returns the list of indices.

  ## Examples

      iex> list_indices()
      [%Index{}, ...]

  """
  def list_indices do
    Repo.all(Index)
  end

  @doc """
  Gets a single index.

  Raises `Ecto.NoResultsError` if the Index does not exist.

  ## Examples

      iex> get_index!(123)
      %Index{}

      iex> get_index!(456)
      ** (Ecto.NoResultsError)

  """
  def get_index!(id), do: Repo.get!(Index, id)

  @doc """
  Creates a index.

  ## Examples

      iex> create_index(%{field: value})
      {:ok, %Index{}}

      iex> create_index(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_index(attrs \\ %{}) do
    %Index{}
    |> Index.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a index.

  ## Examples

      iex> update_index(index, %{field: new_value})
      {:ok, %Index{}}

      iex> update_index(index, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_index(%Index{} = index, attrs) do
    index
    |> Index.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a index.

  ## Examples

      iex> delete_index(index)
      {:ok, %Index{}}

      iex> delete_index(index)
      {:error, %Ecto.Changeset{}}

  """
  def delete_index(%Index{} = index) do
    Repo.delete(index)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking index changes.

  ## Examples

      iex> change_index(index)
      %Ecto.Changeset{data: %Index{}}

  """
  def change_index(%Index{} = index, attrs \\ %{}) do
    Index.changeset(index, attrs)
  end

  alias Loggregate.Indices.UserAccess

  @doc """
  Returns the list of index_admins.

  ## Examples

      iex> list_index_admins()
      [%UserAccess{}, ...]

  """
  def list_index_admins do
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

  alias Loggregate.Indices.SubUser

  @doc """
  Returns the list of index_users.

  ## Examples

      iex> list_index_users()
      [%SubUser{}, ...]

  """
  def list_index_users do
    Repo.all(SubUser)
  end

  @doc """
  Gets a single sub_user.

  Raises `Ecto.NoResultsError` if the Sub user does not exist.

  ## Examples

      iex> get_sub_user!(123)
      %SubUser{}

      iex> get_sub_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sub_user!(id), do: Repo.get!(SubUser, id)

  @doc """
  Creates a sub_user.

  ## Examples

      iex> create_sub_user(%{field: value})
      {:ok, %SubUser{}}

      iex> create_sub_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sub_user(attrs \\ %{}) do
    %SubUser{}
    |> SubUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sub_user.

  ## Examples

      iex> update_sub_user(sub_user, %{field: new_value})
      {:ok, %SubUser{}}

      iex> update_sub_user(sub_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sub_user(%SubUser{} = sub_user, attrs) do
    sub_user
    |> SubUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sub_user.

  ## Examples

      iex> delete_sub_user(sub_user)
      {:ok, %SubUser{}}

      iex> delete_sub_user(sub_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sub_user(%SubUser{} = sub_user) do
    Repo.delete(sub_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sub_user changes.

  ## Examples

      iex> change_sub_user(sub_user)
      %Ecto.Changeset{data: %SubUser{}}

  """
  def change_sub_user(%SubUser{} = sub_user, attrs \\ %{}) do
    SubUser.changeset(sub_user, attrs)
  end

  alias Loggregate.Indices.IndexServer

  @doc """
  Returns the list of index_servers.

  ## Examples

      iex> list_index_servers()
      [%IndexServer{}, ...]

  """
  def list_index_servers do
    Repo.all(IndexServer)
  end

  @doc """
  Gets a single index_server.

  Raises `Ecto.NoResultsError` if the Index server does not exist.

  ## Examples

      iex> get_index_server!(123)
      %IndexServer{}

      iex> get_index_server!(456)
      ** (Ecto.NoResultsError)

  """
  def get_index_server!(id), do: Repo.get!(IndexServer, id)

  @doc """
  Creates a index_server.

  ## Examples

      iex> create_index_server(%{field: value})
      {:ok, %IndexServer{}}

      iex> create_index_server(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_index_server(attrs \\ %{}) do
    %IndexServer{}
    |> IndexServer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a index_server.

  ## Examples

      iex> update_index_server(index_server, %{field: new_value})
      {:ok, %IndexServer{}}

      iex> update_index_server(index_server, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_index_server(%IndexServer{} = index_server, attrs) do
    index_server
    |> IndexServer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a index_server.

  ## Examples

      iex> delete_index_server(index_server)
      {:ok, %IndexServer{}}

      iex> delete_index_server(index_server)
      {:error, %Ecto.Changeset{}}

  """
  def delete_index_server(%IndexServer{} = index_server) do
    Repo.delete(index_server)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking index_server changes.

  ## Examples

      iex> change_index_server(index_server)
      %Ecto.Changeset{data: %IndexServer{}}

  """
  def change_index_server(%IndexServer{} = index_server, attrs \\ %{}) do
    IndexServer.changeset(index_server, attrs)
  end
end
