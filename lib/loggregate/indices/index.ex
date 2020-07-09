defmodule Loggregate.Indices.Index do
  use Ecto.Schema
  import Ecto.Changeset

  schema "indices" do
    field :name, :string
    has_many :sub_user_ids, Loggregate.Indices.SubUser, references: :name, foreign_key: :index_id
    has_many :sub_users, through: [:sub_user_ids, :user]
    has_many :index_admins, Loggregate.Indices.UserAccess, references: :name, foreign_key: :index_id
    has_many :admin_users, through: [:index_admins, :user]

    timestamps()
  end

  @doc false
  def changeset(index, attrs) do
    index
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
