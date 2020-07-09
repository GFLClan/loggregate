defmodule Loggregate.Repo.Migrations.CreateIndexAdmins do
  use Ecto.Migration

  def change do
    create table(:index_admins) do
      add :user_id, references(:users, on_delete: :nothing, column: :steamid, type: :string)
      add :index_id, references(:indices, on_delete: :nothing, column: :name, type: :string)

      timestamps()
    end

    create index(:index_admins, [:user_id])
    create index(:index_admins, [:index_id])
  end
end
