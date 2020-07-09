defmodule Loggregate.Repo.Migrations.CreateServerAccess do
  use Ecto.Migration

  def change do
    create table(:server_access) do
      add :user_id, references(:users, on_delete: :nothing, column: :steamid, type: :string)
      add :server_id, references(:server_mapping, on_delete: :nothing, column: :server_id)

      timestamps()
    end

    create index(:server_access, [:user_id])
    create index(:server_access, [:server_id])
  end
end
