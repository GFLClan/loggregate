defmodule Loggregate.AccountsTest do
  use Loggregate.DataCase

  alias Loggregate.Accounts

  describe "users" do
    alias Loggregate.Accounts.User

    @valid_attrs %{name: "some name", password: "some password"}
    @update_attrs %{name: "some updated name", password: "some updated password"}
    @invalid_attrs %{name: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == "some name"
      assert user.password == "some password"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.name == "some updated name"
      assert user.password == "some updated password"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "acl" do
    alias Loggregate.Accounts.ACLEntry

    @valid_attrs %{index_access: "some index_access", server_access: "some server_access"}
    @update_attrs %{index_access: "some updated index_access", server_access: "some updated server_access"}
    @invalid_attrs %{index_access: nil, server_access: nil}

    def acl_entry_fixture(attrs \\ %{}) do
      {:ok, acl_entry} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_acl_entry()

      acl_entry
    end

    test "list_acl/0 returns all acl" do
      acl_entry = acl_entry_fixture()
      assert Accounts.list_acl() == [acl_entry]
    end

    test "get_acl_entry!/1 returns the acl_entry with given id" do
      acl_entry = acl_entry_fixture()
      assert Accounts.get_acl_entry!(acl_entry.id) == acl_entry
    end

    test "create_acl_entry/1 with valid data creates a acl_entry" do
      assert {:ok, %ACLEntry{} = acl_entry} = Accounts.create_acl_entry(@valid_attrs)
      assert acl_entry.index_access == "some index_access"
      assert acl_entry.server_access == "some server_access"
    end

    test "create_acl_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_acl_entry(@invalid_attrs)
    end

    test "update_acl_entry/2 with valid data updates the acl_entry" do
      acl_entry = acl_entry_fixture()
      assert {:ok, %ACLEntry{} = acl_entry} = Accounts.update_acl_entry(acl_entry, @update_attrs)
      assert acl_entry.index_access == "some updated index_access"
      assert acl_entry.server_access == "some updated server_access"
    end

    test "update_acl_entry/2 with invalid data returns error changeset" do
      acl_entry = acl_entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_acl_entry(acl_entry, @invalid_attrs)
      assert acl_entry == Accounts.get_acl_entry!(acl_entry.id)
    end

    test "delete_acl_entry/1 deletes the acl_entry" do
      acl_entry = acl_entry_fixture()
      assert {:ok, %ACLEntry{}} = Accounts.delete_acl_entry(acl_entry)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_acl_entry!(acl_entry.id) end
    end

    test "change_acl_entry/1 returns a acl_entry changeset" do
      acl_entry = acl_entry_fixture()
      assert %Ecto.Changeset{} = Accounts.change_acl_entry(acl_entry)
    end
  end
end
