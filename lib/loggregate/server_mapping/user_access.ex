defmodule Loggregate.ServerMapping.UserAccess do
  use Ecto.Schema
  import Ecto.Changeset

  schema "server_access" do
    belongs_to :user, Loggregate.Accounts.User, references: :steamid, type: :string
    belongs_to :server, Loggregate.ServerMapping.ServerMapping, references: :server_id

    timestamps()
  end

  @doc false
  def changeset(user_access, attrs) do
    user_access
    |> cast(attrs, [:user_id, :server_id])
    |> validate_required([:user_id, :server_id])
  end
end
