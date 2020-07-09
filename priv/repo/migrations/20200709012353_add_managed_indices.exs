defmodule Loggregate.Repo.Migrations.AddManagedIndices do
  use Ecto.Migration

  def change do
    create index(:users, [:steamid], unique: true)
    create index(:server_mapping, [:server_id], unique: true)
  end
end
