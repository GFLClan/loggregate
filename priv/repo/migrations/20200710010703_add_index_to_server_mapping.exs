defmodule Loggregate.Repo.Migrations.AddIndexToServerMapping do
  use Ecto.Migration

  def change do
    alter table(:server_mapping) do
      add :index_id, references(:indices)
    end
  end
end
