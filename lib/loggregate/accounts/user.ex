defmodule Loggregate.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :steamid, :string
    field :name, :string
    field :admin, :boolean
    has_many :index_access, Loggregate.Indices.UserAccess, references: :steamid, foreign_key: :user_id
    has_many :indices, through: [:index_access, :index]
    has_many :server_access, Loggregate.ServerMapping.UserAccess, references: :steamid, foreign_key: :user_id
    has_many :servers, through: [:server_access, :server]
    has_many :parent_indices, Loggregate.Indices.SubUser, references: :steamid, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:steamid, :name, :admin])
    |> validate_required([:steamid, :name, :admin])
    |> unique_constraint(:steamid)
  end
end
