defmodule Loggregate.Repo.Migrations.CreateAcl do
  use Ecto.Migration

  def change do
    create table(:acl) do
      add :server_access, :string, default: "none"
      add :index_access, :string, default: "none"
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all, column: :steamid, type: :string)
      add :server_id, references(:server_mapping, on_delete: :delete_all, column: :server_id)
      add :index_id, references(:indices, on_delete: :delete_all)

      timestamps()
    end

    create index(:acl, [:user_id])
    create index(:acl, [:server_id])
    create index(:acl, [:index_id])
  end
end
