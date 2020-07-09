defmodule Loggregate.Repo.Migrations.CreateIndexUsers do
  use Ecto.Migration

  def change do
    create table(:index_users) do
      add :user_id, references(:users, on_delete: :nothing, type: :string, column: :steamid)
      add :index_id, references(:indices, on_delete: :nothing, type: :string, column: :name)

      timestamps()
    end

    create index(:index_users, [:user_id])
    create index(:index_users, [:index_id])
  end
end
