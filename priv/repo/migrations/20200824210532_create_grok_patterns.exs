defmodule Loggregate.Repo.Migrations.CreateGrokPatterns do
  use Ecto.Migration

  def change do
    create table(:grok_patterns) do
      add :name, :string
      add :pattern, :string

      timestamps()
    end

    create unique_index(:grok_patterns, [:name])

    flush()

    {:ok, _} = Loggregate.Grok.create_pattern(%{name: "STEAMID3", pattern: "\\[U:(?:1|0):%{POSINT}\\]"})
    {:ok, _} = Loggregate.Grok.create_pattern(%{name: "STEAMID2", pattern: "STEAM_(?:0|1):(?:0|1):%{POSINT}"})
    {:ok, _} = Loggregate.Grok.create_pattern(%{name: "STEAMID", pattern: "(?:%{STEAMID3}|%{STEAMID2})"})
  end
end
