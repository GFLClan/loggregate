defmodule Loggregate.Indices.IndexServer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "index_servers" do
    belongs_to :server, Loggregate.ServerMapping.ServerMapping, references: :server_id
    belongs_to :index, Loggregate.Indices.Index, references: :name, type: :string, foreign_key: :index_name

    timestamps()
  end

  @doc false
  def changeset(index_server, attrs) do
    index_server
    |> cast(attrs, [:server_id, :index_name])
    |> validate_required([:server_id, :index_name])
  end
end
