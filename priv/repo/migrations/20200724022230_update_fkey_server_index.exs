defmodule Loggregate.Repo.Migrations.UpdateFkeyServerIndex do
  use Ecto.Migration

  def change do
    drop constraint(:server_mapping, :server_mapping_index_id_fkey)
    alter table(:server_mapping) do
      modify :index_id, references(:indices, on_delete: :delete_all, on_update: :update_all)
    end
  end
end
