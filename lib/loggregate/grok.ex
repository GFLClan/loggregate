defmodule Loggregate.Grok do
  @moduledoc """
  The Grok context.
  """

  import Ecto.Query, warn: false
  alias Loggregate.Repo
  require Logger
  alias Loggregate.Grok.Pattern

  @doc """
  Returns the list of grok_patterns.

  ## Examples

      iex> list_grok_patterns()
      [%Pattern{}, ...]

  """
  def list_grok_patterns do
    Repo.all(Pattern)
  end

  @doc """
  Gets a single pattern.

  Raises `Ecto.NoResultsError` if the Pattern does not exist.

  ## Examples

      iex> get_pattern!(123)
      %Pattern{}

      iex> get_pattern!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pattern!(id), do: Repo.get!(Pattern, id)

  @doc """
  Creates a pattern.

  ## Examples

      iex> create_pattern(%{field: value})
      {:ok, %Pattern{}}

      iex> create_pattern(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pattern(attrs \\ %{}) do
    %Pattern{}
    |> Pattern.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pattern.

  ## Examples

      iex> update_pattern(pattern, %{field: new_value})
      {:ok, %Pattern{}}

      iex> update_pattern(pattern, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pattern(%Pattern{} = pattern, attrs) do
    pattern
    |> Pattern.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pattern.

  ## Examples

      iex> delete_pattern(pattern)
      {:ok, %Pattern{}}

      iex> delete_pattern(pattern)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pattern(%Pattern{} = pattern) do
    Repo.delete(pattern)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pattern changes.

  ## Examples

      iex> change_pattern(pattern)
      %Ecto.Changeset{data: %Pattern{}}

  """
  def change_pattern(%Pattern{} = pattern, attrs \\ %{}) do
    Pattern.changeset(pattern, attrs)
  end

  alias Loggregate.Grok.MessagePattern

  @doc """
  Returns the list of grok_msg_patterns.

  ## Examples

      iex> list_grok_msg_patterns()
      [%MessagePattern{}, ...]

  """
  def list_grok_msg_patterns do
    Repo.all(MessagePattern)
  end

  @doc """
  Gets a single message_pattern.

  Raises `Ecto.NoResultsError` if the Message pattern does not exist.

  ## Examples

      iex> get_message_pattern!(123)
      %MessagePattern{}

      iex> get_message_pattern!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message_pattern!(id), do: Repo.get!(MessagePattern, id)

  @doc """
  Creates a message_pattern.

  ## Examples

      iex> create_message_pattern(%{field: value})
      {:ok, %MessagePattern{}}

      iex> create_message_pattern(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message_pattern(attrs \\ %{}) do
    %MessagePattern{}
    |> MessagePattern.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message_pattern.

  ## Examples

      iex> update_message_pattern(message_pattern, %{field: new_value})
      {:ok, %MessagePattern{}}

      iex> update_message_pattern(message_pattern, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message_pattern(%MessagePattern{} = message_pattern, attrs) do
    message_pattern
    |> MessagePattern.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message_pattern.

  ## Examples

      iex> delete_message_pattern(message_pattern)
      {:ok, %MessagePattern{}}

      iex> delete_message_pattern(message_pattern)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message_pattern(%MessagePattern{} = message_pattern) do
    Repo.delete(message_pattern)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message_pattern changes.

  ## Examples

      iex> change_message_pattern(message_pattern)
      %Ecto.Changeset{data: %MessagePattern{}}

  """
  def change_message_pattern(%MessagePattern{} = message_pattern, attrs \\ %{}) do
    MessagePattern.changeset(message_pattern, attrs)
  end

  def reload_config_cache() do
    patterns = Enum.reduce(list_grok_patterns(), %{}, fn pattern, patterns ->
      Map.put(patterns, pattern.name, pattern.pattern)
    end)
    msg_patterns = Enum.map(list_grok_msg_patterns(), fn pattern ->
      case GrokEX.compile_predicate(pattern.pattern, patterns: patterns) do
        {:error, error} ->
          Logger.error("Error compiling grok pattern", grok_error: error)
          :error
        {:ok, predicate} -> fn message ->
          case predicate.(message) do
            :no_match -> :no_match
            matches -> Map.put(matches, "type", pattern.type)
          end
        end
      end
    end) |> Enum.filter(&(&1 != :error))
    aliases = list_grok_name_aliases() |> Enum.map(&({&1.name, &1.alias})) |> Map.new()
    :ets.insert(:loggregate_grok_config, {:patterns, msg_patterns})
    :ets.insert(:loggregate_grok_config, {:aliases, aliases})
  end

  def fetch_patterns() do
    case :ets.lookup(:loggregate_grok_config, :patterns) do
      [{:patterns, predicates}] -> predicates
      _ -> []
    end
  end

  def fetch_aliases() do
    case :ets.lookup(:loggregate_grok_config, :aliases) do
      [{:aliases, aliases}] -> aliases
      _ -> %{}
    end
  end

  alias Loggregate.Grok.NameAliases

  @doc """
  Returns the list of grok_name_aliases.

  ## Examples

      iex> list_grok_name_aliases()
      [%NameAliases{}, ...]

  """
  def list_grok_name_aliases do
    Repo.all(NameAliases)
  end

  @doc """
  Gets a single name_aliases.

  Raises `Ecto.NoResultsError` if the Name aliases does not exist.

  ## Examples

      iex> get_name_aliases!(123)
      %NameAliases{}

      iex> get_name_aliases!(456)
      ** (Ecto.NoResultsError)

  """
  def get_name_aliases!(id), do: Repo.get!(NameAliases, id)

  @doc """
  Creates a name_aliases.

  ## Examples

      iex> create_name_aliases(%{field: value})
      {:ok, %NameAliases{}}

      iex> create_name_aliases(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_name_aliases(attrs \\ %{}) do
    %NameAliases{}
    |> NameAliases.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a name_aliases.

  ## Examples

      iex> update_name_aliases(name_aliases, %{field: new_value})
      {:ok, %NameAliases{}}

      iex> update_name_aliases(name_aliases, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_name_aliases(%NameAliases{} = name_aliases, attrs) do
    name_aliases
    |> NameAliases.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a name_aliases.

  ## Examples

      iex> delete_name_aliases(name_aliases)
      {:ok, %NameAliases{}}

      iex> delete_name_aliases(name_aliases)
      {:error, %Ecto.Changeset{}}

  """
  def delete_name_aliases(%NameAliases{} = name_aliases) do
    Repo.delete(name_aliases)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking name_aliases changes.

  ## Examples

      iex> change_name_aliases(name_aliases)
      %Ecto.Changeset{data: %NameAliases{}}

  """
  def change_name_aliases(%NameAliases{} = name_aliases, attrs \\ %{}) do
    NameAliases.changeset(name_aliases, attrs)
  end
end
