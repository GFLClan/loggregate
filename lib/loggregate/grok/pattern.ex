defmodule Loggregate.Grok.Pattern do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grok_patterns" do
    field :name, :string
    field :pattern, :string

    timestamps()
  end

  @doc false
  def changeset(pattern, attrs) do
    pattern
    |> cast(attrs, [:name, :pattern])
    |> validate_required([:name, :pattern])
    |> unique_constraint(:name)
  end
end
