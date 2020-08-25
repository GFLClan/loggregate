defmodule Loggregate.GrokTest do
  use Loggregate.DataCase

  alias Loggregate.Grok

  describe "grok_patterns" do
    alias Loggregate.Grok.Pattern

    @valid_attrs %{name: "some name", pattern: "some pattern"}
    @update_attrs %{name: "some updated name", pattern: "some updated pattern"}
    @invalid_attrs %{name: nil, pattern: nil}

    def pattern_fixture(attrs \\ %{}) do
      {:ok, pattern} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Grok.create_pattern()

      pattern
    end

    test "list_grok_patterns/0 returns all grok_patterns" do
      pattern = pattern_fixture()
      assert Grok.list_grok_patterns() == [pattern]
    end

    test "get_pattern!/1 returns the pattern with given id" do
      pattern = pattern_fixture()
      assert Grok.get_pattern!(pattern.id) == pattern
    end

    test "create_pattern/1 with valid data creates a pattern" do
      assert {:ok, %Pattern{} = pattern} = Grok.create_pattern(@valid_attrs)
      assert pattern.name == "some name"
      assert pattern.pattern == "some pattern"
    end

    test "create_pattern/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grok.create_pattern(@invalid_attrs)
    end

    test "update_pattern/2 with valid data updates the pattern" do
      pattern = pattern_fixture()
      assert {:ok, %Pattern{} = pattern} = Grok.update_pattern(pattern, @update_attrs)
      assert pattern.name == "some updated name"
      assert pattern.pattern == "some updated pattern"
    end

    test "update_pattern/2 with invalid data returns error changeset" do
      pattern = pattern_fixture()
      assert {:error, %Ecto.Changeset{}} = Grok.update_pattern(pattern, @invalid_attrs)
      assert pattern == Grok.get_pattern!(pattern.id)
    end

    test "delete_pattern/1 deletes the pattern" do
      pattern = pattern_fixture()
      assert {:ok, %Pattern{}} = Grok.delete_pattern(pattern)
      assert_raise Ecto.NoResultsError, fn -> Grok.get_pattern!(pattern.id) end
    end

    test "change_pattern/1 returns a pattern changeset" do
      pattern = pattern_fixture()
      assert %Ecto.Changeset{} = Grok.change_pattern(pattern)
    end
  end

  describe "grok_msg_patterns" do
    alias Loggregate.Grok.MessagePattern

    @valid_attrs %{name: "some name", pattern: "some pattern"}
    @update_attrs %{name: "some updated name", pattern: "some updated pattern"}
    @invalid_attrs %{name: nil, pattern: nil}

    def message_pattern_fixture(attrs \\ %{}) do
      {:ok, message_pattern} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Grok.create_message_pattern()

      message_pattern
    end

    test "list_grok_msg_patterns/0 returns all grok_msg_patterns" do
      message_pattern = message_pattern_fixture()
      assert Grok.list_grok_msg_patterns() == [message_pattern]
    end

    test "get_message_pattern!/1 returns the message_pattern with given id" do
      message_pattern = message_pattern_fixture()
      assert Grok.get_message_pattern!(message_pattern.id) == message_pattern
    end

    test "create_message_pattern/1 with valid data creates a message_pattern" do
      assert {:ok, %MessagePattern{} = message_pattern} = Grok.create_message_pattern(@valid_attrs)
      assert message_pattern.name == "some name"
      assert message_pattern.pattern == "some pattern"
    end

    test "create_message_pattern/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grok.create_message_pattern(@invalid_attrs)
    end

    test "update_message_pattern/2 with valid data updates the message_pattern" do
      message_pattern = message_pattern_fixture()
      assert {:ok, %MessagePattern{} = message_pattern} = Grok.update_message_pattern(message_pattern, @update_attrs)
      assert message_pattern.name == "some updated name"
      assert message_pattern.pattern == "some updated pattern"
    end

    test "update_message_pattern/2 with invalid data returns error changeset" do
      message_pattern = message_pattern_fixture()
      assert {:error, %Ecto.Changeset{}} = Grok.update_message_pattern(message_pattern, @invalid_attrs)
      assert message_pattern == Grok.get_message_pattern!(message_pattern.id)
    end

    test "delete_message_pattern/1 deletes the message_pattern" do
      message_pattern = message_pattern_fixture()
      assert {:ok, %MessagePattern{}} = Grok.delete_message_pattern(message_pattern)
      assert_raise Ecto.NoResultsError, fn -> Grok.get_message_pattern!(message_pattern.id) end
    end

    test "change_message_pattern/1 returns a message_pattern changeset" do
      message_pattern = message_pattern_fixture()
      assert %Ecto.Changeset{} = Grok.change_message_pattern(message_pattern)
    end
  end

  describe "grok_name_aliases" do
    alias Loggregate.Grok.NameAliases

    @valid_attrs %{alias: "some alias", name: "some name"}
    @update_attrs %{alias: "some updated alias", name: "some updated name"}
    @invalid_attrs %{alias: nil, name: nil}

    def name_aliases_fixture(attrs \\ %{}) do
      {:ok, name_aliases} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Grok.create_name_aliases()

      name_aliases
    end

    test "list_grok_name_aliases/0 returns all grok_name_aliases" do
      name_aliases = name_aliases_fixture()
      assert Grok.list_grok_name_aliases() == [name_aliases]
    end

    test "get_name_aliases!/1 returns the name_aliases with given id" do
      name_aliases = name_aliases_fixture()
      assert Grok.get_name_aliases!(name_aliases.id) == name_aliases
    end

    test "create_name_aliases/1 with valid data creates a name_aliases" do
      assert {:ok, %NameAliases{} = name_aliases} = Grok.create_name_aliases(@valid_attrs)
      assert name_aliases.alias == "some alias"
      assert name_aliases.name == "some name"
    end

    test "create_name_aliases/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grok.create_name_aliases(@invalid_attrs)
    end

    test "update_name_aliases/2 with valid data updates the name_aliases" do
      name_aliases = name_aliases_fixture()
      assert {:ok, %NameAliases{} = name_aliases} = Grok.update_name_aliases(name_aliases, @update_attrs)
      assert name_aliases.alias == "some updated alias"
      assert name_aliases.name == "some updated name"
    end

    test "update_name_aliases/2 with invalid data returns error changeset" do
      name_aliases = name_aliases_fixture()
      assert {:error, %Ecto.Changeset{}} = Grok.update_name_aliases(name_aliases, @invalid_attrs)
      assert name_aliases == Grok.get_name_aliases!(name_aliases.id)
    end

    test "delete_name_aliases/1 deletes the name_aliases" do
      name_aliases = name_aliases_fixture()
      assert {:ok, %NameAliases{}} = Grok.delete_name_aliases(name_aliases)
      assert_raise Ecto.NoResultsError, fn -> Grok.get_name_aliases!(name_aliases.id) end
    end

    test "change_name_aliases/1 returns a name_aliases changeset" do
      name_aliases = name_aliases_fixture()
      assert %Ecto.Changeset{} = Grok.change_name_aliases(name_aliases)
    end
  end
end
