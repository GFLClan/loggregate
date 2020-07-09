defmodule Loggregate.Repo.Migrations.CreateIndices do
  use Ecto.Migration

  def change do
    create table(:indices) do
      add :name, :string

      timestamps()
    end

    create unique_index(:indices, [:name])
  end
end
