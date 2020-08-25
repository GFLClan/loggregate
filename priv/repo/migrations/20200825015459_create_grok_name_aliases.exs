defmodule Loggregate.Repo.Migrations.CreateGrokNameAliases do
  use Ecto.Migration

  def change do
    create table(:grok_name_aliases) do
      add :name, :string
      add :alias, :string

      timestamps()
    end

    create unique_index(:grok_name_aliases, [:name])

    flush()

    {:ok, _} = Loggregate.Grok.create_name_aliases(%{name: "who_steamid", alias: "who.steamid"})
    {:ok, _} = Loggregate.Grok.create_name_aliases(%{name: "who_name", alias: "who.name"})
    {:ok, _} = Loggregate.Grok.create_name_aliases(%{name: "who_address", alias: "who.address"})
    {:ok, _} = Loggregate.Grok.create_name_aliases(%{name: "who_port", alias: "who.port"})
    {:ok, _} = Loggregate.Grok.create_name_aliases(%{name: "from_addr_port", alias: "from_addr.port"})
    {:ok, _} = Loggregate.Grok.create_name_aliases(%{name: "from_addr_address", alias: "from_addr.address"})
    {:ok, _} = Loggregate.Grok.create_name_aliases(%{name: "cvar_name", alias: "cvar.name"})
    {:ok, _} = Loggregate.Grok.create_name_aliases(%{name: "cvar_value", alias: "cvar.value"})
  end
end
