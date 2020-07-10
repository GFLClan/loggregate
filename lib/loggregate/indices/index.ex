defmodule Loggregate.Indices.Index do
  use Ecto.Schema
  import Ecto.Changeset

  schema "indices" do
    field :name, :string

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
