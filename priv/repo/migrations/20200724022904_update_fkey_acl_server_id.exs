defmodule Loggregate.Repo.Migrations.UpdateFkeyAclServerId do
  use Ecto.Migration

  def change do
    drop constraint(:acl, :acl_server_id_fkey)
    alter table(:acl) do
      modify :server_id, references(:server_mapping, on_delete: :delete_all, on_update: :update_all, column: :server_id)
    end
  end
end
