defmodule Loggregate.Indices.Index do
  use Ecto.Schema
  import Ecto.Changeset

  schema "indices" do
    field :name, :string
    has_many :user_mappings, Loggregate.Accounts.ACLEntry
    has_many :managed_users, through: [:user_mappings, :target_user]
    has_many :servers, Loggregate.ServerMapping.ServerMapping

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
