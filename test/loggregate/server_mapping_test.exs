defmodule Loggregate.ServerMappingTest do
  use Loggregate.DataCase

  alias Loggregate.ServerMapping

  describe "server_access" do
    alias Loggregate.ServerMapping.UserAccess

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def user_access_fixture(attrs \\ %{}) do
      {:ok, user_access} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ServerMapping.create_user_access()

      user_access
    end

    test "list_server_access/0 returns all server_access" do
      user_access = user_access_fixture()
      assert ServerMapping.list_server_access() == [user_access]
    end

    test "get_user_access!/1 returns the user_access with given id" do
      user_access = user_access_fixture()
      assert ServerMapping.get_user_access!(user_access.id) == user_access
    end

    test "create_user_access/1 with valid data creates a user_access" do
      assert {:ok, %UserAccess{} = user_access} = ServerMapping.create_user_access(@valid_attrs)
    end

    test "create_user_access/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ServerMapping.create_user_access(@invalid_attrs)
    end

    test "update_user_access/2 with valid data updates the user_access" do
      user_access = user_access_fixture()
      assert {:ok, %UserAccess{} = user_access} = ServerMapping.update_user_access(user_access, @update_attrs)
    end

    test "update_user_access/2 with invalid data returns error changeset" do
      user_access = user_access_fixture()
      assert {:error, %Ecto.Changeset{}} = ServerMapping.update_user_access(user_access, @invalid_attrs)
      assert user_access == ServerMapping.get_user_access!(user_access.id)
    end

    test "delete_user_access/1 deletes the user_access" do
      user_access = user_access_fixture()
      assert {:ok, %UserAccess{}} = ServerMapping.delete_user_access(user_access)
      assert_raise Ecto.NoResultsError, fn -> ServerMapping.get_user_access!(user_access.id) end
    end

    test "change_user_access/1 returns a user_access changeset" do
      user_access = user_access_fixture()
      assert %Ecto.Changeset{} = ServerMapping.change_user_access(user_access)
    end
  end
end
