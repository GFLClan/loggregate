defmodule Loggregate.ServerMapping.ServerMapping do
  use Ecto.Schema
  import Ecto.Changeset

  schema "server_mapping" do
    field :server_id, :integer
    field :server_name, :string
    has_many :users_access, Loggregate.ServerMapping.UserAccess, foreign_key: :server_id, references: :server_id
    has_many :users, through: [:users_access, :user]
    has_one :index_mapping, Loggregate.Indices.IndexServer, references: :server_id, foreign_key: :server_id
    has_one :index, through: [:index_mapping, :index]

    timestamps()
  end

  @doc false
  def changeset(server_mapping, attrs) do
    server_mapping
    |> cast(attrs, [:server_id, :server_name])
    |> validate_required([:server_id, :server_name])
  end
end
