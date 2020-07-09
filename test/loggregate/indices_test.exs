defmodule Loggregate.IndicesTest do
  use Loggregate.DataCase

  alias Loggregate.Indices

  describe "indices" do
    alias Loggregate.Indices.Index

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def index_fixture(attrs \\ %{}) do
      {:ok, index} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Indices.create_index()

      index
    end

    test "list_indices/0 returns all indices" do
      index = index_fixture()
      assert Indices.list_indices() == [index]
    end

    test "get_index!/1 returns the index with given id" do
      index = index_fixture()
      assert Indices.get_index!(index.id) == index
    end

    test "create_index/1 with valid data creates a index" do
      assert {:ok, %Index{} = index} = Indices.create_index(@valid_attrs)
      assert index.name == "some name"
    end

    test "create_index/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Indices.create_index(@invalid_attrs)
    end

    test "update_index/2 with valid data updates the index" do
      index = index_fixture()
      assert {:ok, %Index{} = index} = Indices.update_index(index, @update_attrs)
      assert index.name == "some updated name"
    end

    test "update_index/2 with invalid data returns error changeset" do
      index = index_fixture()
      assert {:error, %Ecto.Changeset{}} = Indices.update_index(index, @invalid_attrs)
      assert index == Indices.get_index!(index.id)
    end

    test "delete_index/1 deletes the index" do
      index = index_fixture()
      assert {:ok, %Index{}} = Indices.delete_index(index)
      assert_raise Ecto.NoResultsError, fn -> Indices.get_index!(index.id) end
    end

    test "change_index/1 returns a index changeset" do
      index = index_fixture()
      assert %Ecto.Changeset{} = Indices.change_index(index)
    end
  end

  describe "index_admins" do
    alias Loggregate.Indices.UserAccess

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def user_access_fixture(attrs \\ %{}) do
      {:ok, user_access} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Indices.create_user_access()

      user_access
    end

    test "list_index_admins/0 returns all index_admins" do
      user_access = user_access_fixture()
      assert Indices.list_index_admins() == [user_access]
    end

    test "get_user_access!/1 returns the user_access with given id" do
      user_access = user_access_fixture()
      assert Indices.get_user_access!(user_access.id) == user_access
    end

    test "create_user_access/1 with valid data creates a user_access" do
      assert {:ok, %UserAccess{} = user_access} = Indices.create_user_access(@valid_attrs)
    end

    test "create_user_access/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Indices.create_user_access(@invalid_attrs)
    end

    test "update_user_access/2 with valid data updates the user_access" do
      user_access = user_access_fixture()
      assert {:ok, %UserAccess{} = user_access} = Indices.update_user_access(user_access, @update_attrs)
    end

    test "update_user_access/2 with invalid data returns error changeset" do
      user_access = user_access_fixture()
      assert {:error, %Ecto.Changeset{}} = Indices.update_user_access(user_access, @invalid_attrs)
      assert user_access == Indices.get_user_access!(user_access.id)
    end

    test "delete_user_access/1 deletes the user_access" do
      user_access = user_access_fixture()
      assert {:ok, %UserAccess{}} = Indices.delete_user_access(user_access)
      assert_raise Ecto.NoResultsError, fn -> Indices.get_user_access!(user_access.id) end
    end

    test "change_user_access/1 returns a user_access changeset" do
      user_access = user_access_fixture()
      assert %Ecto.Changeset{} = Indices.change_user_access(user_access)
    end
  end

  describe "index_users" do
    alias Loggregate.Indices.SubUser

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def sub_user_fixture(attrs \\ %{}) do
      {:ok, sub_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Indices.create_sub_user()

      sub_user
    end

    test "list_index_users/0 returns all index_users" do
      sub_user = sub_user_fixture()
      assert Indices.list_index_users() == [sub_user]
    end

    test "get_sub_user!/1 returns the sub_user with given id" do
      sub_user = sub_user_fixture()
      assert Indices.get_sub_user!(sub_user.id) == sub_user
    end

    test "create_sub_user/1 with valid data creates a sub_user" do
      assert {:ok, %SubUser{} = sub_user} = Indices.create_sub_user(@valid_attrs)
    end

    test "create_sub_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Indices.create_sub_user(@invalid_attrs)
    end

    test "update_sub_user/2 with valid data updates the sub_user" do
      sub_user = sub_user_fixture()
      assert {:ok, %SubUser{} = sub_user} = Indices.update_sub_user(sub_user, @update_attrs)
    end

    test "update_sub_user/2 with invalid data returns error changeset" do
      sub_user = sub_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Indices.update_sub_user(sub_user, @invalid_attrs)
      assert sub_user == Indices.get_sub_user!(sub_user.id)
    end

    test "delete_sub_user/1 deletes the sub_user" do
      sub_user = sub_user_fixture()
      assert {:ok, %SubUser{}} = Indices.delete_sub_user(sub_user)
      assert_raise Ecto.NoResultsError, fn -> Indices.get_sub_user!(sub_user.id) end
    end

    test "change_sub_user/1 returns a sub_user changeset" do
      sub_user = sub_user_fixture()
      assert %Ecto.Changeset{} = Indices.change_sub_user(sub_user)
    end
  end

  describe "index_servers" do
    alias Loggregate.Indices.IndexServer

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def index_server_fixture(attrs \\ %{}) do
      {:ok, index_server} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Indices.create_index_server()

      index_server
    end

    test "list_index_servers/0 returns all index_servers" do
      index_server = index_server_fixture()
      assert Indices.list_index_servers() == [index_server]
    end

    test "get_index_server!/1 returns the index_server with given id" do
      index_server = index_server_fixture()
      assert Indices.get_index_server!(index_server.id) == index_server
    end

    test "create_index_server/1 with valid data creates a index_server" do
      assert {:ok, %IndexServer{} = index_server} = Indices.create_index_server(@valid_attrs)
    end

    test "create_index_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Indices.create_index_server(@invalid_attrs)
    end

    test "update_index_server/2 with valid data updates the index_server" do
      index_server = index_server_fixture()
      assert {:ok, %IndexServer{} = index_server} = Indices.update_index_server(index_server, @update_attrs)
    end

    test "update_index_server/2 with invalid data returns error changeset" do
      index_server = index_server_fixture()
      assert {:error, %Ecto.Changeset{}} = Indices.update_index_server(index_server, @invalid_attrs)
      assert index_server == Indices.get_index_server!(index_server.id)
    end

    test "delete_index_server/1 deletes the index_server" do
      index_server = index_server_fixture()
      assert {:ok, %IndexServer{}} = Indices.delete_index_server(index_server)
      assert_raise Ecto.NoResultsError, fn -> Indices.get_index_server!(index_server.id) end
    end

    test "change_index_server/1 returns a index_server changeset" do
      index_server = index_server_fixture()
      assert %Ecto.Changeset{} = Indices.change_index_server(index_server)
    end
  end
end
