defmodule Loggregate.Repo.Migrations.CreateServerMapping do
  use Ecto.Migration

  def change do
    create table(:server_mapping) do
      add :server_id, :integer, primary_key: true
      add :server_name, :string

      timestamps()
    end
    create index(:server_mapping, [:server_name], unique: true)
  end
end
