defmodule Loggregate.Repo.Migrations.LogWithSteam do
  use Ecto.Migration

  def change do
    drop table(:users)
    create table(:users) do
      add :steamid, :string, primary_key: true
      add :name, :string
      add :admin, :boolean

      timestamps()
    end
  end
end
