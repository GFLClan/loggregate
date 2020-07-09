defmodule Loggregate.Repo.Migrations.CreateIndexServers do
  use Ecto.Migration

  def change do
    create table(:index_servers) do
      add :server_id, references(:server_mapping, on_delete: :nothing, column: :server_id)
      add :index_name, references(:indices, on_delete: :nothing, type: :string, column: :name)

      timestamps()
    end

    create index(:index_servers, [:server_id])
    create index(:index_servers, [:index_name])
  end
end
