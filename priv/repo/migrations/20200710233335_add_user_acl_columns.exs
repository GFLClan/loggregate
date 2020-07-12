defmodule Loggregate.Repo.Migrations.AddUserAclColumns do
  use Ecto.Migration

  def change do
    alter table(:acl) do
      add :target_user_id, references(:users, on_delete: :delete_all, on_update: :update_all, column: :steamid, type: :string)
      add :user_access, :string, default: "none"
    end
  end
end
