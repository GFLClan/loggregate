defmodule Loggregate.Indices.SubUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "index_users" do
    belongs_to :user, Loggregate.Accounts.User, references: :steamid, type: :string
    belongs_to :index, Loggregate.Indices.Index, references: :name, type: :string

    timestamps()
  end

  @doc false
  def changeset(sub_user, attrs) do
    sub_user
    |> cast(attrs, [:user_id, :index_id])
    |> validate_required([:user_id, :index_id])
  end
end
