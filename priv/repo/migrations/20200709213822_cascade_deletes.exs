defmodule Loggregate.Repo.Migrations.CascadeDeletes do
  use Ecto.Migration

  def change do
    drop_if_exists constraint(:index_servers, [:server_id], name: :index_servers_server_id_fkey)
    drop_if_exists constraint(:index_servers, [:index_name], name: :index_servers_index_name_fkey)
    alter table(:index_servers) do
      modify :server_id, references(:server_mapping, on_delete: :delete_all, column: :server_id)
      modify :index_name, references(:indices, on_delete: :delete_all, type: :string, column: :name)
    end

    drop_if_exists constraint(:index_users, [:user_id], name: :index_users_user_id_fkey)
    drop_if_exists constraint(:index_users, [:index_id], name: :index_users_index_id_fkey)
    alter table(:index_users) do
      modify :user_id, references(:users, on_delete: :delete_all, type: :string, column: :steamid)
      modify :index_id, references(:indices, on_delete: :delete_all, type: :string, column: :name)
    end

    drop_if_exists constraint(:server_access, [:user_id], name: :server_access_user_id_fkey)
    drop_if_exists constraint(:server_access, [:server_id], name: :server_access_server_id_fkey)
    alter table(:server_access) do
      modify :user_id, references(:users, on_delete: :delete_all, column: :steamid, type: :string)
      modify :server_id, references(:server_mapping, on_delete: :delete_all, column: :server_id)
    end

    drop_if_exists constraint(:index_admins, [:user_id], name: :index_admins_user_id_fkey)
    drop_if_exists constraint(:index_admins, [:index_id], name: :index_admins_index_id_fkey)
    alter table(:index_admins) do
      modify :user_id, references(:users, on_delete: :delete_all, column: :steamid, type: :string)
      modify :index_id, references(:indices, on_delete: :delete_all, column: :name, type: :string)
    end
  end
end
