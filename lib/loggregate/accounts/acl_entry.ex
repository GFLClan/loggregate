defmodule Loggregate.Accounts.ACLEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "acl" do
    field :index_access, :string
    field :server_access, :string
    field :user_access, :string
    belongs_to :user, Loggregate.Accounts.User, references: :steamid, type: :string
    belongs_to :server, Loggregate.ServerMapping.ServerMapping, references: :server_id
    belongs_to :index, Loggregate.Indices.Index
    belongs_to :target_user, Loggregate.Accounts.User, references: :steamid, type: :string

    timestamps()
  end

  @doc false
  def changeset(acl_entry, attrs) do
    acl_entry
    |> cast(attrs, [:server_access, :index_access, :server_id, :index_id, :user_id])
    |> validate_required([])
  end
end
