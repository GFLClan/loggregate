defmodule Loggregate.Indices.UserAccess do
  use Ecto.Schema
  import Ecto.Changeset

  schema "index_admins" do
    belongs_to :user, Loggregate.Accounts.User, references: :steamid, type: :string
    belongs_to :index, Loggregate.Indices.Index, references: :name, type: :string

    timestamps()
  end

  @doc false
  def changeset(user_access, attrs) do
    user_access
    |> cast(attrs, [:user_id, :index_id])
    |> validate_required([:user_id, :index_id])
  end
end
